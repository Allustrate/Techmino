return{
    mesDisp=function(P)
        setFont(45)
        mStr(("%.1f"):format(P.stat.atk),63,190)
        mStr(("%.2f"):format(P.stat.atk/P.stat.row),63,310)
        mText(drawableText.atk,63,243)
        mText(drawableText.eff,63,363)
    end,
    dropPiece=function(P)
        if P.stat.atk>=100 then
            P:win('finish')
        end
    end
}
