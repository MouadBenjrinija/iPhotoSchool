//
//  CoreDataStackMock.swift
//  iPhotoSchoolTests
//
//  Created by MOUAD BENJRINIJA on 17/1/2023.
//

import Foundation
import Combine
import CoreData
@testable import iPhotoSchool

class CoreDataStackMock: LocalDataSource, Mock {
  struct ContextSnapshot: Equatable {
    let inserted: Int, updated: Int, deleted: Int
  }
  enum Action: Equatable {
    case fetch(String, ContextSnapshot)
    case update(String, ContextSnapshot)
  }

  var recorder = MockActionRecorder<Action>(expected: [])

  func fetch<T>(_ persistable: T.Type, request:
                @escaping () -> NSFetchRequest<T.ManagedObject>)
      -> AnyPublisher<[T], Error> where T: Persistable {
    do {
      let fetchRequest = request()
      let context = container.viewContext
      let managedObjects = try context.fetch(fetchRequest)

      record(action: .fetch("\(T.WrappedType.self)", .init(inserted: 0, updated: 0, deleted: 0)))
      return Just(managedObjects)
        .setFailureType(to: Error.self)
        .mapped()
        .eraseToAnyPublisher()
    } catch {
      return Fail<[T], Error>(error: error)
        .eraseToAnyPublisher()
    }
  }

  func update<T: Persistable>(_ operation: @escaping DBOperation<[T]>)
      -> AnyPublisher<[T], Error> {
    do {
      let context = container.viewContext
      context.reset()
      let result = try operation(context)
      self.record(action: .update("\(T.WrappedType.self)", context.snapshot))
      try context.save()
      context.reset()
      return Just(result).setFailureType(to: Error.self).eraseToAnyPublisher()
    } catch {
      return Fail<[T], Error>(error: error).eraseToAnyPublisher()
    }
  }

  func insert<T: Persistable>(_ objects: [T]) -> AnyPublisher<[T], Error> {
    return update { context in
      let result = try objects
        .map { try $0.insert(in: context) }
        .map(T.init(managedObject:))
      return result
    }
  }

  func preload<T: Persistable>(_ objects: [T]) throws {
    try objects.forEach { _ = try $0.insert(in: container.viewContext) }
    if container.viewContext.hasChanges {
      try container.viewContext.save()
    }
    container.viewContext.reset()
  }

  lazy var container: NSPersistentContainer = {
    let container = NSPersistentContainer(name: CoreDataStack.name)
    let storeDescription = NSPersistentStoreDescription()
    storeDescription.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [storeDescription]
    let dispatchGroup = DispatchGroup()
    dispatchGroup.enter()
    container.loadPersistentStores { _, error in
      if let error = error { fatalError("\(error)") }
      dispatchGroup.leave()
    }
    dispatchGroup.wait()
    return container
  }()
}

extension NSManagedObjectContext {
  var snapshot: CoreDataStackMock.ContextSnapshot {
    .init(inserted: insertedObjects.count,
          updated: updatedObjects.count,
          deleted: deletedObjects.count)
  }
}
