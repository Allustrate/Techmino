return{
    mesDisp=function(P)
        setFont(55)
        local r=200-P.stat.row
        if r<0 then r=0 end
        mStr(r,63,265)
        PLY.draw.drawTargetLine(P,r)
    end,
    dropPiece=function(P)
        if P.stat.row>=200 then
            P:win('finish')
        end
    end
}
