local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScrollFrame = PlayerGui:WaitForChild("Seed_Shop"):WaitForChild("Frame"):WaitForChild("ScrollingFrame")
local TimerLabel = PlayerGui:WaitForChild("Seed_Shop"):WaitForChild("Frame"):WaitForChild("Frame"):WaitForChild("Timer")
local HttpService = game:GetService("HttpService")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local fruits = {
    "Daffodil", "Coconut", "Apple", "Pumpkin", "Pepper", "Cacao", "Orange Tulip", "Carrot",
    "Mango", "Tomato", "Blueberry", "Strawberry", "Mushroom", "Bamboo", "Ember Lily",
    "Corn", "Dragon Fruit", "Watermelon", "Cactus", "Sugar Apple", "Beanstalk", "Grape"
}

local function parseStock(stockString)
    local num = tonumber(stockString:match("%d+"))
    return num or 0
end

local function extractData()
    local extractedData = {}
    for _, fruitName in ipairs(fruits) do
        local item = ScrollFrame:FindFirstChild(fruitName)
        if item and item:IsA("Frame") then
            local stockValue = 0
            local costValue = nil
            local mainFrame = item:FindFirstChild("Main_Frame")
            if mainFrame then
                local stockLabel = mainFrame:FindFirstChild("Stock_Text")
                if stockLabel then
                    stockValue = parseStock(stockLabel.Text)
                end
            end
            local frame = item:FindFirstChild("Frame")
            if frame then
                local shecklesBuy = frame:FindFirstChild("Sheckles_Buy")
                if shecklesBuy then
                    local inStock = shecklesBuy:FindFirstChild("In_Stock")
                    if inStock then
                        local costLabel = inStock:FindFirstChild("Cost_Text")
                        if costLabel then
                            costValue = costLabel.Text
                        end
                    end
                end
            end
            table.insert(extractedData, { ItemName = fruitName, Stock = stockValue, Cost = costValue })
        else
            table.insert(extractedData, { ItemName = fruitName, Stock = 0, Cost = nil })
        end
    end
    return extractedData
end

local function saveData()
    local data = {}
    data.Timestamp = os.date("%Y-%m-%d %H:%M:%S")
    data.Seeds = extractData()
    local jsonData = HttpService:JSONEncode(data)
    writefile("ShopData.json", jsonData)
    print("--- Shop Data Saved ---")
    print(jsonData)
end

local function antiAFK()
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = Character.HumanoidRootPart
        local originalPosition = humanoidRootPart.Position
        
        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, 2)
        wait(0.5)
        
        humanoidRootPart.CFrame = CFrame.new(originalPosition)
    end
end

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
end)

saveData()

local lastAntiAFKTime = tick()
local lastShopCheckTime = tick()

while true do
    local currentTime = tick()
    
    if currentTime - lastAntiAFKTime >= 5 then
        antiAFK()
        lastAntiAFKTime = currentTime
    end
    
    local text = TimerLabel.Text
    local minutes = tonumber(text:match("(%d+)m")) or 0
    local seconds = tonumber(text:match("(%d+)s")) or 0
    local totalSeconds = minutes * 60 + seconds
    
    if totalSeconds <= 0 and currentTime - lastShopCheckTime >= 5 then
        saveData()
        lastShopCheckTime = currentTime
    end
    
    wait(0.1)
end
