return{
    env={
        noTele=true,
        mindas=7,minarr=1,minsdarr=1,
        sequence="bagES",
        hook_drop=require'parts.eventsets.bigWallGen'.hook_drop,
        eventSet='big_h',
        bg='cubes',bgm='push',
    },
    score=function(P)return{math.min(P.modeData.maxCombo,100),P.stat.time}end,
    scoreDisp=function(D)return D[1].." Combo   "..STRING.time(D[2])end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        local L=P.stat.row
        if L>=200 then
            local T=P.stat.time
            return
            T<=160 and 5 or
            T<=280 and 4 or
            3
        else
            return
            L>=100 and 2 or
            L>=50 and 1 or
            L>=10 and 0
        end
    end,
}
