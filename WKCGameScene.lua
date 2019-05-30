--region WKCGameScene.lua
--Author : gouwc
--Date   :
local BaseScene = require("core.BaseScene")
local MessageCenter = require("core.MessageCenter")
local WKCBackgroundLogic=import(".WKCBackgroundLogic")
local WKCStartLogic =import(".WKCStartLogic")
local WKCBallLogic =import(".WKCBallLogic")
local WKCScoreLogic =import(".WKCScoreLogic")
local WKCEffLogic=import(".WKCEffLogic")
local WKCResultLogic=import(".WKCResultLogic")
local WKCMaskLogic=import(".WKCMaskLogic")
local WKCWordLogic=import(".WKCWordLogic")
local WKCLeftTopLogic=import(".WKCLeftTopLogic")
local WKCShareLogic=import(".WKCShareLogic")
local WKCTipLogic=import(".WKCTipLogic")


cc.FileUtils:getInstance():addSearchPath("res/weekendCasino/effect")

-- local WKCGameScene = class("WKCGameScene", cc.load("mvc").ViewBase)
local WKCGameScene = class("WKCGameScene", BaseScene)

-- WKCGameScene.RESOURCE_FILENAME = "res/weekendCasino/WKCGameScene.csb"

function WKCGameScene:setCsbPathName( ... )
    -- rawset(self.class, "RESOURCE_FILENAME", "res/weekendCasino/WKCGameScene.csb")
end

function WKCGameScene:testMaze()
    math.randomseed(os.time())
    -- body
    local visible = cc.Director:getInstance():getVisibleSize()

    local pixSize = 75
    local mapSize = {}
    mapSize.width = 750
    mapSize.height = 750
    local wall = 10

    local totalCell = {}

    local totalX = mapSize.width / pixSize
    local totalY = mapSize.height / pixSize
    
    local drawNode = cc.DrawNode:create()
    --地图
    self:drawMap(drawNode, visible, mapSize, cc.c4f(1, 1, 1, 1))
    self:addChild(drawNode)

    for  i = 1, totalX do
        for j = 1, totalY do
            local cell = {}
            cell.mx = i
            cell.my = j
            cell.actived = false
            local cellNode = self:createCell(i, j, visible, pixSize, mapSize, wall)
            cell.cellNode = cellNode
            table.insert(totalCell, cell)
        end
    end
    self:startMazeOne(drawNode, totalCell)
end

function WKCGameScene:drawMap(drawNode,visibleSize, mapSize, bgColor)
    -- body
    local p1 = cc.p((visibleSize.width - mapSize.width) / 2, (visibleSize.height - mapSize.height) / 2)
    local p2 = cc.p(visibleSize.width - p1.x, visibleSize.height - p1.y)
    drawNode:drawSolidRect(p1, p2, bgColor)
end

function WKCGameScene:createCell(x, y, visibleSize, pixSize, mapSize, wall)
    local drawNode = cc.DrawNode:create()
    local p1 = cc.p((visibleSize.width - mapSize.width) / 2, (visibleSize.height - mapSize.height) / 2)
    local p2 = cc.p(p1.x + (x - 1) * pixSize, p1.y + (y - 1) * pixSize)
    local p3 = cc.p(p2.x + pixSize, p2.y + pixSize)
    drawNode:drawSolidRect(p2, p3, cc.c4f(1, 1, 1, 1))

    local p4 = cc.p(p2.x + wall, p2.y + wall)
    local p5 = cc.p(p3.x - wall, p3.y - wall)

    drawNode:drawSolidRect(p4, p5, cc.c4f(0, 0, 0, 1))
    drawNode.p2 = p2
    drawNode.p3 = p3
    drawNode.p4 = p4
    drawNode.p5 = p5
    self:addChild(drawNode)
    return drawNode
end

function WKCGameScene:openWall(cell1, cell2)
    local x = cell2.mx - cell1.mx
    local y = cell2.my - cell1.my

    if x == 1 and y == 0 then
        self:cellOpen("right", cell1)
        self:cellOpen("left", cell2)
    elseif x == 0 and y == -1 then
        self:cellOpen("down", cell1)
        self:cellOpen("up", cell2)
    elseif x == -1 and y == 0 then
        self:cellOpen("left", cell1)
        self:cellOpen("right", cell2)
    elseif x == 0 and y == 1 then
        self:cellOpen("up", cell1)
        self:cellOpen("down", cell2)
    end

end

function WKCGameScene:cellOpen(direction, cell)
    local p1 = cc.p(0, 0)
    local p2 = cc.p(0, 0)
    local cell = cell.cellNode
    if direction == "up" then
        p1 = cc.p(cell.p4.x, cell.p5.y)
        p2 = cc.p(cell.p5.x, cell.p3.y)
    elseif direction == "down" then
        p1 = cc.p(cell.p4.x, cell.p2.y)
        p2 = cc.p(cell.p5.x, cell.p4.y)
    elseif direction == "left" then
        p1 = cc.p(cell.p2.x, cell.p4.y)
        p2 = cc.p(cell.p4.x, cell.p5.y)
    elseif direction == "right" then
        p1 = cc.p(cell.p5.x, cell.p4.y)
        p2 = cc.p(cell.p3.x, cell.p5.y)
    end
    cell:drawSolidRect(p1, p2, cc.c4f(0, 0, 0, 1))
end

function WKCGameScene:startMazeOne(drawNode, totalCell)
    if #totalCell > 0 then
        totalCell[1].actived = true
        local function checkActiveCell(totalCell)
            local hasNotActiveCell = false
            for k,v in pairs(totalCell) do
                if not v.actived then
                    hasNotActiveCell = true
                    break
                end
            end
            return hasNotActiveCell
        end

        local function checkRoundCell(totalCell, cell)
            local findNeighbor = false
            local neighbors = {}
            for k,v in pairs(totalCell) do
                local absX = math.abs(v.mx - cell.mx)
                local absY = math.abs(v.my - cell.my)
                if (absX + absY) == 1  and not v.actived then
                    findNeighbor = true
                    table.insert(neighbors, v)
                end
            end

            return findNeighbor, neighbors
        end

        local currentCell = totalCell[1]
        local usedCells = {}

        while(checkActiveCell(totalCell))
        do
            local findNeighbor, neighbors = checkRoundCell(totalCell, currentCell)
            if findNeighbor then
                local idx = math.random(#neighbors)
                table.insert(usedCells, currentCell)
                self:openWall(currentCell, neighbors[idx])
                currentCell = neighbors[idx]
                currentCell.actived = true
            else 
                if #usedCells > 0 then
                    currentCell = usedCells[#usedCells]
                    table.remove(usedCells)
                end
            end 
        end
    end
end

function WKCGameScene:onCreate()
    self:testMaze()
    -- -- self.super.onCreate(self)
    -- MessageCenter.callNativeLog("WKCGameScene:onCreate")

    -- self.d_isCanClickBack=false
    -- self.m_updataTimer=nil

    -- self.m_layout1=self.resourceNode_:getChildByName("Panel_1");
    -- self.m_effLayout=self.resourceNode_:getChildByName("Panel_Eff");
    
    -- self.m_layout2=self.resourceNode_:getChildByName("Panel_2");
    -- self.m_zebraTarget=self.m_layout2:getChildByName("Image_zebra")
    -- self.m_zebraTarget:setLocalZOrder(2)
    -- self.m_ballTarget=self.m_layout2:getChildByName("Image_ballbase")
    -- self.m_ballTarget:setVisible(false)


    -- self.m_layout3=self.resourceNode_:getChildByName("Panel_3");

    -- self.m_bgLayout=self.resourceNode_:getChildByName("Panel_BG");
  
    -- self.m_layout4=self.resourceNode_:getChildByName("Panel_4");
    -- self.m_goImg=self.m_layout4:getChildByName("Image_go");
    -- self.m_startBtn=self.m_layout4:getChildByName("startbtn");
    -- -- self.m_startBtn:addTouchEventListener(handler(self, self.onStart))

    -- self.m_title=self.m_layout4:getChildByName("sharepagetitle_8")

    -- self.m_topLayout=self.resourceNode_:getChildByName("Panel_top")

    -- self.m_resultLayout=self.resourceNode_:getChildByName("Panel_Result");

    -- self.m_leftTopLayout=self.resourceNode_:getChildByName("Panel_LeftTop");

    -- self.m_tipLayout=self.resourceNode_:getChildByName("Panel_Tip");

    -- self.m_shareLayout=self.resourceNode_:getChildByName("Panel_Share");
    -- self.m_shareLayout:setVisible(false)

    -- --////适配相关////--
    -- self.d_scaleRatio=1.0       --适配缩放系数
    -- self.d_offX=0               --宽屏适配偏移
    -- self.d_visibleSize = cc.Director:getInstance():getVisibleSize();
    -- WKCLuaLog("visiblesize h:"..self.d_visibleSize.height.."  w:"..self.d_visibleSize.width)
    -- if self.d_visibleSize.width <750 then    --窄屏适配
    --     self.d_scaleRatio=self.d_visibleSize.width/750  
    --     -- self.m_layout1:setScaleX(self.d_scaleRatio)
    --     -- self.m_bgLayout:setScaleX(self.d_scaleRatio)
    --     self.m_effLayout:setScale(self.d_scaleRatio)
    --     self.m_layout2:setScale(self.d_scaleRatio)
    --     self.m_layout3:setScale(self.d_scaleRatio)
    --     self.m_layout4:setScale(self.d_scaleRatio)
    --     self.m_topLayout:setScale(self.d_scaleRatio)
    --     self.m_topLayout:setPosition(cc.p(cc.p(0,1334)))
    --     self.m_resultLayout:setScale(self.d_scaleRatio)
    --     self.m_resultLayout:setPosition(cc.p(cc.p(0,1334*(1-self.d_scaleRatio)/2)))
    --     self.m_shareLayout:setScale(self.d_scaleRatio)
    --     self.m_shareLayout:setPosition(cc.p(cc.p(0,1334*(1-self.d_scaleRatio)/2)))

    --     self.m_leftTopLayout:setScale(self.d_scaleRatio)
    --     self.m_leftTopLayout:setPosition(cc.p(cc.p(0,1334)))

    --     self.m_tipLayout:setScale(self.d_scaleRatio)

    -- elseif self.d_visibleSize.width >750 then   --宽屏适配
    --     local posX=(self.d_visibleSize.width-750)/2.0
    --     self.m_layout1:setPositionX(posX)
    --     self.m_bgLayout:setPositionX(posX)
    --     self.m_effLayout:setPositionX(posX)
    --     self.m_layout2:setPositionX(posX)
    --     self.m_layout2:setPositionX(posX)
    --     self.m_layout3:setPositionX(posX)
    --     self.m_layout4:setPositionX(posX)
    --     self.m_topLayout:setPositionX(posX)
    --     self.m_resultLayout:setPositionX(posX)
    --     self.m_shareLayout:setPositionX(posX)

    --     self.m_tipLayout:setPositionX(posX)

    --     self.d_offX=posX
    -- end

    -- --logic
    -- self.m_backgroundLogic=WKCBackgroundLogic:create(self)
    -- self.m_startLogic=WKCStartLogic:create(self)
    -- self.m_ballLogic=WKCBallLogic:create(self)
    -- self.m_scoreLogic=WKCScoreLogic:create(self)
    -- self.m_effLogic=WKCEffLogic:create(self)
    -- self.m_resultLogic=WKCResultLogic:create(self)
    -- self.m_maskLogic=WKCMaskLogic:create(self)
    -- self.m_wordLogic=WKCWordLogic:create(self)
    -- self.m_leftTopLogic=WKCLeftTopLogic:create(self)
    -- self.m_shareLogic=WKCShareLogic:create(self)
    -- self.m_tipLogic=WKCTipLogic:create(self)

    -- AudioEngine.setMusicVolume(0.5) 
    -- AudioEngine.setEffectsVolume(1.0) 

    -- -- self:onInitSlider()
    -- self:onInit()

end

-- function WKCGameScene:onInitSlider()

--     -- local lo_silder = ccui.Slider:create()
--     --             :loadBarTexture("weekendCasino/png/mask.png",0)
--     --             :setScale9Enabled(true)
--     --             :loadSlidBallTextures("weekendCasino/png/jinpai.png","weekendCasino/png/jinpai.png","weekendCasino/png/jinpai.png",0)
--     --             :setPosition(300,100)
--     --             :setContentSize(600,100)
--     --             :setPercent(80)
--     --             :addTo(self)
--     --             :addEventListener(function(ref,eventType)
--     --                 cocos_print(ref)
--     --                 cocos_print(eventType)
--     --             end)

--     local function sliderEvent(sender, eventType)
        
--         if eventType == ccui.SliderEventType.percentChanged then 
--             local slider1 = self:getChildByTag(1000)
--             local percent = slider1:getPercent()
-- --             cc.UserDefault:getInstance():getBoolForKey("soundable", true)
-- --             cc.UserDefault:getInstance():getIntegerForKey("soundvalue",percent)
--             cocos_print("音效：" .. percent)
-- --            AudioEngine.setEffectsVolume(GlobalUserItem.nSound / percent)
-- --             AudioEngine.setEffectsVolume(percent / 100.00)
--         end
        
--     end
        
--     local slider1 = ccui.Slider:create()
--     slider1:setTag(1000)
--     slider1:setTouchEnabled(true)

--     slider1:loadBarTexture("weekendCasino/png/mask.png")  --背景阴影图片 
--     slider1:loadSlidBallTextures("weekendCasino/png/jinpai.png", "weekendCasino/png/jinpai.png", "") --第一张是点击图片 ，第二张是点击后图片
--     slider1:loadProgressBarTexture("weekendCasino/png/jinpai.png")--滑动图片
--     slider1:setPosition(cc.p(1080,420))
--     slider1:setContentSize(600,100)
--     slider1:setPercent(52)
--     slider1:addEventListenerSlider(sliderEvent)
--     self:addChild(slider1)

-- end

function WKCGameScene:onInit()

    self.d_isStart=false;       --是否答题开始
    self.d_isRunning=false;     --当前是否答题状态中（Go消失后）
    self.d_isRolling=false      --当前是否滚屏中
    self.d_isJumping=false      --当前斑马是否正在跳跃中
    self.d_isFalling=false      --当前斑马是否正在下落中s

    
    self.m_backgroundLogic:onInit()
    self.m_startLogic:onInit()
    self.m_ballLogic:onInit()
    self.m_scoreLogic:onInit()
    self.m_effLogic:onInit()
    self.m_resultLogic:onInit()
    self.m_wordLogic:onInit()
    self.m_leftTopLogic:onInit()
    self.m_tipLogic:onInit()
    
    self:doData()

    self.m_scoreLogic:setCD(self.d_playgroundConfig["levelConfig"]["countingDown"])

    if WKC_APP_VERSION == "3.14.0" then  --如果当前是线上3.14.0版本，不需要等待回调后再go,延迟0.5秒再Go
        WKCLuaLog("线上GO")
        self.m_goImg:stopAllActions()
        performWithDelay(self.m_goImg,function()
            self.m_goImg:stopAllActions()
            self:onGo()
        end,0.5)
    else
        --如果ios那边的准备好了或者是安卓系统马上进入Go动画
        if self._app._isDidAppear==true then
            self:onGo()
        elseif cc.PLATFORM_OS_ANDROID == cc.Application:getInstance():getTargetPlatform() then
            self.m_goImg:stopAllActions()
            performWithDelay(self.m_goImg,function()
                self.m_goImg:stopAllActions()
                self:onGo()
            end,0.5)
        end
    end

end

function WKCGameScene:onGo()
    -- self.m_startLogic:onStart()
    -- if self.m_updataTimer==nil then
    --     self.m_updataTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.onTick ), 0, false)
    -- end
end

function WKCGameScene:onEnable()

end

function WKCGameScene:onDestroy()
    if self.m_updataTimer~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_updataTimer)
    end

    self.m_scoreLogic:onDestroy()
    self.m_leftTopLogic:onDestroy()
    MessageCenter.callNativeLog("WKCGameScene:onDestroy")
end

function WKCGameScene:onTick( dt ) 
    if dt<10.00 then
        self.m_backgroundLogic:onTick(dt)
        self.m_ballLogic:onTick(dt)
        self.m_scoreLogic:onTick(dt)
        self.m_resultLogic:onTick(dt)
        self.m_leftTopLogic:onTick(dt)
    end
end
function WKCGameScene:onEnter()
    self.super.onEnter(self)
    WKCLuaLog("onEnter")
    self.d_isCanClickBack=true
    -- self.m_leftTopLogic:initTouch()
    self._app:addFrog("frog_game_enter")
end

--json数据
function WKCGameScene:doData()
    self.d_configJson={}
    self.d_configJson=self._jsonData

    -- WKCLuaLog("++++++++++++++++++++++++++++++")
    -- dump(self.d_configJson["exercise"])
    -- dump(self.d_configJson["exercise"]["passerInfos"][1]["profiles"])
    -- WKCLuaLog("++++++++++++++++++++++++++++++")

    self.d_exerciseConfig={}
    self.d_exerciseConfig["questions"]=self.d_configJson["exercise"]["questions"]
    self.d_exerciseConfig["passerInfos"]=self.d_configJson["exercise"]["passerInfos"]
    
    self.d_playgroundConfig={}
    local playConfig=self.d_configJson["playground"]["config"]
    self.d_playgroundConfig["questionNum"]=playConfig["questionNum"]
    self.d_playgroundConfig["diffConfig"]=playConfig["diffConfig"]  --单题难度配置
    self.d_playgroundConfig["eggConfigs"]=playConfig["eggConfigs"]  --外层是数组
    self.d_playgroundConfig["levelConfig"]=playConfig["levelConfig"]  --课程进度倒计时配置
    self.d_playgroundConfig["scoreConfig"]=playConfig["scoreConfig"] --单题得分配置
    self.d_playgroundConfig["scoreConfig"]["riseAgainScore"]=20   --自己加的 回升得分
    self.d_playgroundConfig["upgradeConfig"]=playConfig["upgradeConfig"] --升级配置

    -- self.d_playgroundConfig["levelConfig"]["countingDown"]=6

    ---------------------------------------------------------------------------------

    -- self.d_exerciseConfig={}
    -- self.d_exerciseConfig["questions"]={}
    -- self.d_exerciseConfig["questions"][1]={}
    -- self.d_exerciseConfig["questions"][1]["id"]=201
    -- self.d_exerciseConfig["questions"][1]["content"]={}
    -- self.d_exerciseConfig["questions"][1]["content"]["correctAnswer"]={correctIndex=1}
    -- self.d_exerciseConfig["questions"][1]["content"]["options"]={}
    -- self.d_exerciseConfig["questions"][1]["content"]["options"][1]={audioUrl="",imageUrl="",text="flute"}
    -- self.d_exerciseConfig["questions"][1]["content"]["options"][2]={audioUrl="",imageUrl="",text="flute"}
    -- self.d_exerciseConfig["questions"][1]["content"]["question"]={audioUrl="",imageUrl="",text="flute",wordcardId=201}

    -- self.d_exerciseConfig["questions"][2]={}
    -- self.d_exerciseConfig["questions"][2]["id"]=202
    -- self.d_exerciseConfig["questions"][2]["content"]={}
    -- self.d_exerciseConfig["questions"][2]["content"]["correctAnswer"]={correctIndex=1}
    -- self.d_exerciseConfig["questions"][2]["content"]["options"]={}
    -- self.d_exerciseConfig["questions"][2]["content"]["options"][1]={audioUrl="",imageUrl="",text="flute"}
    -- self.d_exerciseConfig["questions"][2]["content"]["options"][2]={audioUrl="",imageUrl="",text="flute"}
    -- self.d_exerciseConfig["questions"][2]["content"]["question"]={audioUrl="",imageUrl="",text="flute",wordcardId=202}


    -- self.d_exerciseConfig["passerInfos"]={}
    -- self.d_exerciseConfig["passerInfos"][1]={}
    -- self.d_exerciseConfig["passerInfos"][1]["score"]=1000
    -- self.d_exerciseConfig["passerInfos"][1]["profiles"]={}
    -- self.d_exerciseConfig["passerInfos"][1]["profiles"][1]={}
    -- self.d_exerciseConfig["passerInfos"][1]["profiles"][1]["userId"]=1
    -- self.d_exerciseConfig["passerInfos"][1]["profiles"][1]["name"]="Lily"
    -- self.d_exerciseConfig["passerInfos"][1]["profiles"][1]["avatarId"]=""
    -- self.d_exerciseConfig["passerInfos"][1]["profiles"][1]["avatarUrl"]=""
    -- self.d_exerciseConfig["passerInfos"][1]["profiles"][1]["birthDay"]=2018
    -- self.d_exerciseConfig["passerInfos"][1]["profiles"][1]["defaultAddressId"]=101

    -- self.d_exerciseConfig["passerInfos"][2]={}
    -- self.d_exerciseConfig["passerInfos"][2]["score"]=1000
    -- self.d_exerciseConfig["passerInfos"][2]["profiles"]={}
    -- self.d_exerciseConfig["passerInfos"][2]["profiles"][1]={}
    -- self.d_exerciseConfig["passerInfos"][2]["profiles"][1]["userId"]=1
    -- self.d_exerciseConfig["passerInfos"][2]["profiles"][1]["name"]="Lily"
    -- self.d_exerciseConfig["passerInfos"][2]["profiles"][1]["avatarId"]=""
    -- self.d_exerciseConfig["passerInfos"][2]["profiles"][1]["avatarUrl"]=""
    -- self.d_exerciseConfig["passerInfos"][2]["profiles"][1]["birthDay"]=2018
    -- self.d_exerciseConfig["passerInfos"][2]["profiles"][1]["defaultAddressId"]=101


    -- self.d_playgroundConfig={}
    -- self.d_playgroundConfig["questionNum"]=60
    -- -- 课程进度倒计时配置
    -- self.d_playgroundConfig["levelConfig"]={}
    -- self.d_playgroundConfig["levelConfig"]["level"]=1
    -- self.d_playgroundConfig["levelConfig"]["countingDown"]=6
    -- --单题得分配置
    -- self.d_playgroundConfig["scoreConfig"]={}
    -- self.d_playgroundConfig["scoreConfig"]["normalScore"]=100
    -- self.d_playgroundConfig["scoreConfig"]["upgradeScore"]=200
    -- self.d_playgroundConfig["scoreConfig"]["highDifficultyScore"]=200
    -- self.d_playgroundConfig["scoreConfig"]["highDifficultyWithUpgradeScore"]=400
    -- self.d_playgroundConfig["scoreConfig"]["riseAgainScore"]=20   --自己加的 回升得分
    -- --彩蛋配置，可能有多个
    -- self.d_playgroundConfig["eggConfigs"]={}
    -- self.d_playgroundConfig["eggConfigs"][1]={}
    -- self.d_playgroundConfig["eggConfigs"][1]["questionIdx"]=3
    -- self.d_playgroundConfig["eggConfigs"][1]["duration"]=3
    -- self.d_playgroundConfig["eggConfigs"][2]={}
    -- self.d_playgroundConfig["eggConfigs"][2]["questionIdx"]=10
    -- self.d_playgroundConfig["eggConfigs"][2]["duration"]=3
    -- self.d_playgroundConfig["eggConfigs"][3]={}
    -- self.d_playgroundConfig["eggConfigs"][3]["questionIdx"]=15
    -- self.d_playgroundConfig["eggConfigs"][3]["duration"]=3
    -- self.d_playgroundConfig["eggConfigs"][4]={}
    -- self.d_playgroundConfig["eggConfigs"][4]["questionIdx"]=20
    -- self.d_playgroundConfig["eggConfigs"][4]["duration"]=3
    -- --升级配置
    -- self.d_playgroundConfig["upgradeConfig"]={}
    -- self.d_playgroundConfig["upgradeConfig"]["consecutiveCorrectCount"]=5
    -- self.d_playgroundConfig["upgradeConfig"]["speedUp"]=false   --是否加速？可以不需要
    -- --单题难度配置
    -- self.d_playgroundConfig["diffConfig"]={}
    -- self.d_playgroundConfig["diffConfig"]["startScore"]=1000
    -- self.d_playgroundConfig["diffConfig"]["countingDown"]=3
    -- --题目球底图
    -- -- self.d_playgroundConfig["baseImageConfigs"]={}
    -- -- self.d_playgroundConfig["baseImageConfigs"][1]={}
end

function WKCGameScene:onStart()
    self.d_isRunning=true
    WKCLuaLog("WKCGameScene:onStart")
    self.m_ballLogic:onStart()
end

function WKCGameScene:onGameOver()
    self.m_resultLogic:onShow()
end

function WKCGameScene:onKeyBack( ... )
    self.m_leftTopLogic:doBack()
end

--检测当前分数是否刚刚超过同学伙伴,如果刚刚超过返回超过相应同学列表的信息，否则返回nil
function WKCGameScene:checkPassMate(agoScore,nowScore)
    for i=1,# self.d_exerciseConfig["passerInfos"] do
        local passScore=self.d_exerciseConfig["passerInfos"][i]["score"]
        if passScore>agoScore and passScore<=nowScore then
            return self.d_exerciseConfig["passerInfos"][i]["profiles"]
        end
    end
    return nil
end

function WKCGameScene:printTable ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            WKCLuaLog(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        WKCLuaLog(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        WKCLuaLog(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        WKCLuaLog(indent.."["..pos..'] => "'..val..'"')
                    else
                        WKCLuaLog(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                WKCLuaLog(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        WKCLuaLog(tostring(t).." {")
        sub_print_r(t,"  ")
        WKCLuaLog("}")
    else
        sub_print_r(t,"  ")
    end
    WKCLuaLog()
end

return WKCGameScene
