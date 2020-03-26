local int,max,format=math.floor,math.max,string.format
local scene={
	cur="load",--Current scene
	swapping=false,--ifSwapping
	swap={
		tar=nil,	--Swapping target
		style=nil,	--Swapping style
		mid=nil,	--Loading point
		time=nil,	--Full swap time
		draw=nil,	--Swap draw  func
	},
	seq={"quit","slowFade"},--Back sequence
}--scene datas,returned
local sceneInit={
	quit=love.event.quit,
	load=function()
		sceneTemp={
			1,--Loading mode
			1,--Loading counter
			#voiceName,--Loading bar lenth(current)
			require("parts/getTip"),--tip
			skip=false,--if skipping
		}
	end,
	intro=function()
		sceneTemp=0--animation timer
		BGM.play("blank")
	end,
	main=function()
		curBG="none"
		BGM.play("blank")
		destroyPlayers()
		modeEnv={}
		if not players[1]then
			newDemoPlayer(1,900,35,1.1)
		end--create demo player
	end,
	music=function()
		if BGM.nowPlay then
			for i=1,#musicID do
				if musicID[i]==BGM.nowPlay then
					sceneTemp=i--music select
					return
				end
			end
		else
			sceneTemp=1
		end
	end,
	mode=function(org)
		curBG="none"
		BGM.play("blank")
		destroyPlayers()
		local cam=mapCam
		cam.zoomK=org=="main"and 5 or 1
		if cam.sel then
			local M=modes[cam.sel]
			cam.x,cam.y=M.x*cam.k+180,M.y*cam.k
			cam.x1,cam.y1=cam.x,cam.y
		end
	end,
	custom=function()
		sceneTemp=1--option select
		destroyPlayers()
		curBG=customRange.bg[customSel[12]]
		BGM.play(customRange.bgm[customSel[13]])
	end,
	draw=function()
		curBG="none"
		sceneTemp={
			sure=0,
			pen=1,
			x=1,y=1,
			demo=false,
		}
	end,
	play=function()
		love.keyboard.setKeyRepeat(false)
		restartCount=0
		if needResetGameData then
			resetGameData()
			needResetGameData=nil
		end
		curBG=modeEnv.bg
	end,
	pause=function(org)
		local S=players[1].stat
		sceneTemp={
			timer=org=="play"and 0 or 50,
			toTime(S.time),
			S.key.."/"..S.rotate.."/"..S.hold,
			S.piece.."  "..(int(S.piece/S.time*100)*.01).."PPS",
			format("%d %.2fLPM",S.row,S.row/S.time*60),
			format("%d %.2fAPM",S.atk,S.atk/S.time*60),
			format("%d %.2fSPM",S.send,S.send/S.time*60),
			format("%d(%d-%d)",S.pend,S.recv,S.recv-S.pend),
			S.clear_1.."/"..S.clear_2.."/"..S.clear_3.."/"..S.clear_4,
			"["..S.spin_0.."]/"..S.spin_1.."/"..S.spin_2.."/"..S.spin_3,
			S.b2b.."[+"..S.b3b.."]",
			S.pc,
			format("%.3f",S.atk/S.row),
			S.extraPiece,
			format("%.2f%%",100*max(1-S.extraRate/S.piece,0)),
		}
	end,
	setting_game=function()
		curBG="none"
	end,
	setting_graphic=function()
		curBG="none"
	end,
	setting_sound=function()
		sceneTemp={last=0,jump=0}--last sound time,animation count(10→0)
		curBG="none"
	end,
	setting_control=function()
		sceneTemp={
			das=setting.das,
			arr=setting.arr,
			pos=0,
			dir=1,
			wait=30,
		}
		curBG="strap"
	end,
	setting_key=function()
		sceneTemp={
			board=1,
			kb=1,js=1,
			kS=false,jS=false,
		}
	end,
	setting_touch=function()
		curBG="game2"
		sceneTemp={
			default=1,
			snap=1,
			sel=nil,
		}
	end,
	setting_touchSwitch=function()
		curBG="matrix"
	end,
	help=function()
		curBG="none"
	end,
	stat=function()
		local S=stat
		sceneTemp={
			S.run,
			S.game,
			toTime(S.time),
			S.key,
			S.rotate,
			S.hold,
			S.piece,
			S.row,
			S.atk.."("..S.send..")",
			format("%d(%d-%d)",S.pend,S.recv,S.recv-S.pend),
			format("%d/%d/%d/%d",S.clear_1,S.clear_2,S.clear_3,S.clear_4),
			format("[%d]/%d/%d/%d",S.spin_0,S.spin_1,S.spin_2,S.spin_3),
			S.b2b.."[+"..S.b3b.."]",
			S.pc,
			format("%.2f",S.atk/S.row),
			format("%d[%.3f%%]",S.extraPiece,100*max(1-S.extraRate/S.piece,0)),
		}
	end,
	history=function()
		curBG="strap"
		sceneTemp={require("updateLog"),1}--scroll pos
	end,
	quit=function()
		love.timer.sleep(.3)
		love.event.quit()
	end,
}
local gc=love.graphics
local swap={
	none={1,0,NULL},
	flash={8,1,function()gc.clear(1,1,1)end},
	fade={30,15,function(t)
		local t=t>15 and 2-t/15 or t/15
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.w,scr.h)
	end},
	fade_togame={120,20,function(t)
		local t=t>20 and (120-t)/100 or t/20
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.w,scr.h)
	end},
	slowFade={180,90,function(t)
		local t=t>90 and 2-t/90 or t/90
		gc.setColor(0,0,0,t)
		gc.rectangle("fill",0,0,scr.w,scr.h)
	end},
}--Scene swapping animations
local backFunc={
	load=love.event.quit,
	pause=function()
		love.keyboard.setKeyRepeat(true)
		updateStat()
		clearTask("play")
	end,
	setting_touch=	function()saveVK()end,
	setting_key=	function()saveKeyMap()end,
	setting_game=	function()saveSetting()end,
	setting_graphic=function()saveSetting()end,
	setting_sound=	function()saveSetting()end,
}
function scene.init(s,org)
	if sceneInit[s]then sceneInit[s](org)end
end
function scene.push(tar,style)
	if not scene.swapping then
		local m=#scene.seq
		scene.seq[m+1]=tar or scene.cur
		scene.seq[m+2]=style or"fade"
	end
end
function scene.pop()
	local _=scene.seq
	_[#_-1]=nil
end
function scene.swapTo(tar,style)
	local S=scene.swap
	if not scene.swapping and tar~=scene.cur then
		scene.swapping=true
		if not style then style="fade"end
		S.tar=tar
		S.style=style
		local swap=swap[style]
		S.time=swap[1]
		S.mid=swap[2]
		S.draw=swap[3]
		widget_sel=nil
	end
end
function scene.back()
	if backFunc[scene.cur] then backFunc[scene.cur]()end
	--func when scene end
	local m=#scene.seq
	if m>0 then
		scene.swapTo(scene.seq[m-1],scene.seq[m])
		scene.seq[m],scene.seq[m-1]=nil
		--Poll&Back to preScene
	end
end
return scene