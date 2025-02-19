local gc=love.graphics
local gc_setColor=gc.setColor
local gc_rectangle=gc.rectangle
local gc_print,gc_printf=gc.print,gc.printf

local kb=love.keyboard
local setFont=FONT.set

local listBox=WIDGET.newListBox{name='list',x=50,y=50,w=1200,h=520,lineH=40,drawF=function(rep,id,ifSel)
    if ifSel then
        gc_setColor(1,1,1,.3)
        gc_rectangle('fill',0,0,1200,40)
    end

    setFont(30)
    gc_setColor(.8,.8,.8)
    gc_print(id,10,0)
    if rep.tasUsed then
        gc_setColor(COLOR.R)
        gc_print("TAS",680,1)
    end

    if rep.available then
        gc_setColor(.9,.9,1)
        local modeName=text.modes[rep.mode]
        gc_print(modeName and modeName[1].."  "..modeName[2]or rep.mode,310,0)
        setFont(20)
        gc_setColor(1,1,.8)
        gc_print(rep.date,80,6)
        gc_setColor(1,.4,.4,.6)
        gc_printf(rep.version,0,6,1190,'right')
        gc_setColor(COLOR.Z)
        gc_printf(rep.player,0,6,960,'right')
    else
        gc_setColor(.6,.6,.6)
        gc_print(rep.fileName,80,0)
    end
end}

local scene={}

local function _playRep(fileName)
    local rep=DATA.parseReplay(fileName,true)
    if not rep.available then
        MES.new('error',text.replayBroken)
    elseif MODES[rep.mode]then
        GAME.seed=rep.seed
        GAME.setting=rep.setting
        TABLE.cut(GAME.mod)
        for i=1,#MODOPT do MODOPT[i].sel=0 end
        for _,m in next,rep.mod do
            MODOPT[m[1]+1].sel=m[2]
            table.insert(GAME.mod,MODOPT[m[1]+1])
        end
        GAME.rep={}
        DATA.pumpRecording(rep.data,GAME.rep)

        loadGame(rep.mode,true)
        resetGameData('r')
        PLAYERS[1].username=rep.player
        PLAYERS[1]:startStreaming(GAME.rep)
        GAME.init=false
        GAME.saved=true
        GAME.fromRepMenu=true
        GAME.tasUsed=rep.tasUsed
    else
        MES.new('error',("No mode id: [%s]"):format(rep.mode))
    end
end

function scene.sceneInit()
    BG.set()
    listBox:setList(REPLAY)
    local hide=listBox:getLen()==0
    for i=3,5 do
        scene.widgetList[i].hide=hide
    end
end

function scene.keyDown(key)
    if key=='return'then
        local rep=listBox:getSel()
        if rep then
            _playRep(rep.fileName)
        end
    elseif key=='c'and kb.isDown('lctrl','rctrl')or key=='cC'then
        local rep=listBox:getSel()
        if rep then
            if rep.available and rep.fileName then
                local repStr=loadFile(rep.fileName,'-string')
                if repStr then
                    love.system.setClipboardText(love.data.encode('string','base64',repStr))
                    MES.new('info',text.exportSuccess)
                else
                    MES.new('error',text.replayBroken)
                end
            else
                MES.new('error',text.replayBroken)
            end
        end
    elseif key=='v'and kb.isDown('lctrl','rctrl')or key=='cV'then
        local repStr=love.system.getClipboardText()
        local res,fileData=pcall(love.data.decode,'string','base64',repStr)
        if res then
            local fileName=os.date("replay/%Y_%m_%d_%H%M%S_import.rep")
            local rep=DATA.parseReplayData(fileName,fileData,false)
            if rep.available then
                if saveFile(fileData,fileName,'-d')then
                    table.insert(REPLAY,1,rep)
                    MES.new('info',text.importSuccess)
                end
            else
                MES.new('error',text.dataCorrupted)
            end
        else
            MES.new('error',text.dataCorrupted)
        end
    elseif key=='delete'then
        local rep=listBox:getSel()
        if rep then
            if tryDelete()then
                listBox:remove()
                love.filesystem.remove(rep.fileName)
                for i=1,#REPLAY do
                    if REPLAY[i].fileName==rep.fileName then
                        table.remove(REPLAY,i)
                        break
                    end
                end
                SFX.play('finesseError',.7)
            end
        end
    elseif key=='up'or key=='down'then
        listBox:arrowKey(key)
    else
        return true
    end
end

scene.widgetList={
    listBox,
    WIDGET.newButton{name='import',x=180,y=640,w=140,h=80,color='lB',code=pressKey'cV',font=50,fText=CHAR.icon.import},
    WIDGET.newButton{name='export',x=350,y=640,w=140,h=80,color='lR',code=pressKey'cC',font=50,fText=CHAR.icon.export},
    WIDGET.newButton{name='play',  x=700,y=640,w=170,h=80,color='lY',code=pressKey'return',font=65,fText=CHAR.icon.play},
    WIDGET.newButton{name='delete',x=850,y=640,w=80,h=80,color='lR',code=pressKey'delete',font=50,fText=CHAR.icon.trash},
    WIDGET.newButton{name='back',  x=1140,y=640,w=170,h=80,sound='back',font=60,fText=CHAR.icon.back,code=backScene},
}

return scene
