
__G__TRACKBACK__ = function(msg)
    local msg = debug.traceback(msg, 3)
	
	tracebackLog(msg)
	
    return msg
end




local function main()
	collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	
	require("gameFrameworks.src.preload_framework")
	
    cc.CGame:setPrintColor(0x000F)
    
    local function reloadGameFramework()
		HotRequire("config")
		HotRequire("gameFrameworks.src.framework_config")
		HotRequire("gameFrameworks.src.Constant")
		HotRequire("gameFrameworks.src.osFunc.osFunction")
	end

    -- Windows下直接进入游戏，Android/IOS平台上进入更新场景，
	--UpdateController更新之前先加載
    if TARGET_PLATFORM == cc.PLATFORM_OS_WINDOWS then
		cc.FileUtils:getInstance():addSearchPath("../../../gameFrameworks/res")
		cc.FileUtils:getInstance():addSearchPath("gameFrameworks/res")
		reloadGameFramework()
		
        if WIN32_UPDATE_SWITCH then
            UpdateController = new_class("gameFrameworks.src.game.controller.update_controller")
            UpdateController:enterUpdate()
        else
            require("gameFrameworks.src.preload_game")
            GameController = new_class(luafile.GameController)
            GameController:startGame()
        end
    else
		local function initGameSearchPath()
			local versionCode = osFunction.getVersionCode()
			local mainpath = string.format("version%s/version", tostring(versionCode))
			local versionDir = cc.FileUtils:getInstance():getWritablePath() .. mainpath
			
			local searlist = {}
			print("initGameSearchPath.versionDir：", versionDir)
			if cc.FileUtils:getInstance():isDirectoryExist(versionDir) then
				searlist[#searlist+1] = versionDir
				searlist[#searlist+1] = versionDir .. "/src"
				searlist[#searlist+1] = versionDir .. "/res"
				searlist[#searlist+1] = versionDir .. "/gameFrameworks/res"
			end
			searlist[#searlist+1] = "res"
			searlist[#searlist+1] = "src"
			searlist[#searlist+1] = "gameFrameworks/res"
			
			cc.FileUtils:getInstance():setSearchPaths(searlist)
		end
		--------------------------------------------------------------------------------------------------------------
		initGameSearchPath()
		reloadGameFramework()

        if MOBILE_UPDATE_SWITCH then
            UpdateController = new_class("gameFrameworks.src.game.controller.update_controller")
            UpdateController:enterUpdate()
        else
            require("gameFrameworks.src.preload_game")
            GameController = new_class("gameFrameworks.src.game.controller.update_controller")
            GameController:startGame()
        end
    end
	
	
end

function applicationDidEnterBackground()
    xpcall(function ( ... )
        print("applicationDidEnterBackground")
        if GameController then
            GameController:dispatchEvent({name = GlobalEvent.ENTER_BACKGROUND})
        end
    end, __G__TRACKBACK__)
end

function applicationWillEnterForeground()
    xpcall(function ( ... )
        print("applicationWillEnterForeground")
        if GameController then
            GameController:dispatchEvent({name = GlobalEvent.ENTER_FOREGROUND})
        end
    end, __G__TRACKBACK__)
end





xpcall(main, __G__TRACKBACK__)
