//
//  main.swift
//  cmd
//
//  Created by cn on 2020/12/4.
//

import Foundation

import Lua

func cs(_ c:UnsafePointer<Int8>)->String{
	return String(cString:c)
}

let L = luaL_newstate();
luaL_openlibs(L)

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

let fm = FileManager.default
let data = fm.contents(atPath: luaf)

let luaf = "src/main.lua"
let luas = try! String(contentsOfFile: luaf)

let lr = lua.luaL_loadstring(L, luas);

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
