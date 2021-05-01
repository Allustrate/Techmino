local gc=love.graphics
local death_lock={12,11,10,9,8}
local death_wait={10,9,8,7,6}
local death_fall={10,9,8,7,6}
local function score(P)
	local D=P.modeData

	local c=#P.clearedRow
	if c==0 and D.pt%100==99 then return end
	local s=c<3 and c+1 or c==3 and 5 or 7
	if P.combo>7 then s=s+2
	elseif P.combo>3 then s=s+1
	end
	D.pt=D.pt+s

	if D.pt%100==99 then
		SFX.play('blip_1')
	elseif D.pt>=D.target then--Level up!
		s=D.target/100
		local E=P.gameEnv
		BG.set(s==1 and'rainbow'or s==2 and'rainbow2'or s==3 and'lightning'or s==4 and'lightning2'or'lightning')
		E.lock=death_lock[s]
		E.wait=death_wait[s]
		E.fall=death_fall[s]
		E.das=math.floor(6.9-s*.4)
		if s==3 then
			E.bone=true
		end

		if s==5 then
			D.pt=500
			P:win('finish')
		else
			D.target=D.target+100
			P:showTextF(text.stage:gsub("$1",s),0,-120,80,'fly')
		end
		SFX.play('reach')
	end
end

return{
	color=COLOR.red,
	env={
		noTele=true,
		das=6,arr=1,
		drop=0,
		lock=death_lock[1],
		wait=death_wait[1],
		fall=death_fall[1],
		dropPiece=score,
		task=function(P)
			P.modeData.pt=0
			P.modeData.target=100
		end,
		freshLimit=15,
		bg='bg2',bgm='secret7th',
	},
	slowMark=true,
	load=function()
		PLY.newPlayer(1)
	end,
	mesDisp=function(P)
		setFont(45)
		mStr(P.modeData.pt,69,320)
		mStr(P.modeData.target,69,370)
		gc.rectangle('fill',25,375,90,4)
	end,
	score=function(P)return{P.modeData.pt,P.stat.time}end,
	scoreDisp=function(D)return D[1].."P   "..STRING.time(D[2])end,
	comp=function(a,b)
		return a[1]>b[1]or(a[1]==b[1]and a[2]<b[2])
	end,
	getRank=function(P)
		local S=P.modeData.pt
		if S==500 then
			local T=P.stat.time
			return
			T<=118 and 5 or
			T<=148 and 4 or
			T<=183 and 3 or
			2
		else
			return
			S>=300 and 2 or
			S>=100 and 1 or
			S>=50 and 0
		end
	end,
}