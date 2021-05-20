//
//  Persistence.swift
//  Shared
//
//  Created by cn on 2020/12/4.
//

import CoreData

import lua

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer



    init(inMemory: Bool = false) {
		let L = luaL_newstate();
		luaL_openlibs(L)

		func cs(_ c:UnsafePointer<Int8>)->String{
			return String(cString:c)
		}

		let perrf : lua_CFunction! = {
			let l = $0
			let ps = String.init(format:"lua err:%s", cs(lua_tolstring(l, -1, nil)))
			print(ps)
			return 0
		}

		let pkf:lua_KFunction = {
			let l  = $0
			let a2 = $1
			let cx = $2
			let ps = String.init(format:"lua pkf:%s", cs(lua_tolstring(l, -1, nil)))
			print(ps)
			return 0
		}

		lua_pushcclosure(L, perrf, 0)
		let errf = luaL_ref(L, -1000000-1000)//LUA_REGISTRYINDEX	(-LUAI_MAXSTACK - 1000)
		print("errf:\(errf)")

		lua_atpanic(L, perrf)
		let oldTop = lua.lua_gettop(L);

		let luaf = "src/main.lua"
		let fm = FileManager.default
		let bpath = Bundle.main.path(forResource:luaf, ofType: "")!
		let luas = try! String(contentsOfFile: bpath)

		let lr = luaL_loadstring(L, luas);

		let nArg:Int32 = 0
		let nReturns:Int32 = -1
		let errFunc:Int32 = errf //LuaAPI.load_error_func(_L, errorFuncRef);
		let ctx:Int = 0 //lua_KContext
		let ret = lua.lua_pcallk(L, nArg, nReturns, errFunc, ctx, pkf)
		//var number:Int = 0
		//var output: UnsafeMutablePointer<Int> = UnsafeMutablePointer<Int>(&number)
		let cstr = lua.lua_tolstring(L, 1, nil)
		if cstr != nil {
			let s = cs(cstr!)
			print("Hello, switf-lua [ret:\(ret)] [top:\(s)]")
		}


		container = NSPersistentCloudKitContainer(name: "mtxlua")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
