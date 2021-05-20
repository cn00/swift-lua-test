//
//  luahub.c
//  mtxlua
//
//  Created by cn on 2020/12/4.
//

#include "luahub.h"

void testlua(){
	lua_State *L = luaL_newstate();  /* create state */
	luaL_dostring(L, "print 'hello lua.");
}
