				local select, next, tostring, pcall, getgenv, setmetatable, mathfloor, mathabs, mathcos, mathsin, mathrad, wait = select, next, tostring, pcall, getgenv, setmetatable, math.floor, math.abs, math.cos, math.sin, math.rad, task.wait
				local WorldToViewportPoint, Vector2new, Vector3new, Vector3zero, CFramenew, Drawingnew, Color3fromRGB = nil, Vector2.new, Vector3.new, Vector3.zero, CFrame.new, Drawing.new, Color3.fromRGB

				--// Launching checks

				if not getgenv().AirHub or getgenv().AirHub.WallHack then return end

				--// Services

				local RunService = game:GetService("RunService")
				local UserInputService = game:GetService("UserInputService")
				local Players = game:GetService("Players")
				local LocalPlayer = Players.LocalPlayer
				local Camera = workspace.CurrentCamera

				--// Variables

				local ServiceConnections = {}

				--// Environment

				getgenv().AirHub.WallHack = {
					Settings = {
						Enabled = false,
						TeamCheck = false,
						AliveCheck = true
					},

					Visuals = {
						ChamsSettings = {
							Enabled = false,
							Color = Color3fromRGB(255, 255, 255),
							Transparency = 0.2,
							Thickness = 0,
							Filled = true,
							EntireBody = false -- For R15, keep false to prevent lag
						},

						ESPSettings = {
							Enabled = true,
							TextColor = Color3fromRGB(255, 255, 255),
							TextSize = 14,
							Outline = true,
							OutlineColor = Color3fromRGB(0, 0, 0),
							TextTransparency = 0.7,
							TextFont = Drawing.Fonts.UI, -- UI, System, Plex, Monospace
							Offset = 20,
							DisplayDistance = true,
							DisplayHealth = true,
							DisplayName = true
						},

						TracersSettings = {
							Enabled = true,
							Type = 1, -- 1 - Bottom; 2 - Center; 3 - Mouse
							Transparency = 0.7,
							Thickness = 1,
							Color = Color3fromRGB(255, 255, 255)
						},

						BoxSettings = {
							Enabled = true,
							Type = 1; -- 1 - 3D; 2 - 2D
							Color = Color3fromRGB(255, 255, 255),
							Transparency = 0.7,
							Thickness = 1,
							Filled = false, -- For 2D
							Increase = 1 -- For 3D
						},

						HeadDotSettings = {
							Enabled = true,
							Color = Color3fromRGB(255, 255, 255),
							Transparency = 0.5,
							Thickness = 1,
							Filled = false,
							Sides = 30
						},

						HealthBarSettings = {
							Enabled = false,
							Transparency = 0.8,
							Size = 2,
							Offset = 10,
							OutlineColor = Color3fromRGB(0, 0, 0),
							Blue = 50,
							Type = 3 -- 1 - Top; 2 - Bottom; 3 - Left; 4 - Right
						}
					},

					Crosshair = {
						Settings = {
							Enabled = false,
							Type = 1, -- 1 - Mouse; 2 - Center
							Size = 12,
							Thickness = 1,
							Color = Color3fromRGB(0, 255, 0),
							Transparency = 1,
							GapSize = 5,
							Rotation = 0,
							CenterDot = false,
							CenterDotColor = Color3fromRGB(0, 255, 0),
							CenterDotSize = 1,
							CenterDotTransparency = 1,
							CenterDotFilled = true,
							CenterDotThickness = 1
						},

						Parts = {
							LeftLine = Drawingnew("Line"),
							RightLine = Drawingnew("Line"),
							TopLine = Drawingnew("Line"),
							BottomLine = Drawingnew("Line"),
							CenterDot = Drawingnew("Circle")
						}
					},

					WrappedPlayers = {}
				}

				local Environment = getgenv().AirHub.WallHack

				--// Core Functions

				WorldToViewportPoint = function(...)
					return Camera.WorldToViewportPoint(Camera, ...)
				end

				local function GetPlayerTable(Player)
					for _, v in next, Environment.WrappedPlayers do
						if v.Name == Player.Name then
							return v
						end
					end
				end

				local function AssignRigType(Player)
					local PlayerTable = GetPlayerTable(Player)

					repeat wait(0) until Player.Character

					if Player.Character:FindFirstChild("Torso") and not Player.Character:FindFirstChild("LowerTorso") then
						PlayerTable.RigType = "R6"
					elseif Player.Character:FindFirstChild("LowerTorso") and not Player.Character:FindFirstChild("Torso") then
						PlayerTable.RigType = "R15"
					else
						repeat AssignRigType(Player) until PlayerTable.RigType
					end
				end

				local function InitChecks(Player)
					local PlayerTable = GetPlayerTable(Player)

					PlayerTable.Connections.UpdateChecks = RunService.RenderStepped:Connect(function()
						if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
							if Environment.Settings.AliveCheck then
								PlayerTable.Checks.Alive = Player.Character:FindFirstChildOfClass("Humanoid").Health > 0
							else
								PlayerTable.Checks.Alive = true
							end

							if Environment.Settings.TeamCheck then
								PlayerTable.Checks.Team = Player.TeamColor ~= LocalPlayer.TeamColor
							else
								PlayerTable.Checks.Team = true
							end
						else
							PlayerTable.Checks.Alive = false
							PlayerTable.Checks.Team = false
						end
					end)
				end

				local function UpdateCham(Part, Cham)
					local CorFrame, PartSize = Part.CFrame, Part.Size / 2

					if select(2, WorldToViewportPoint(CorFrame * CFramenew(PartSize.X / 2,  PartSize.Y / 2, PartSize.Z / 2).Position)) and Environment.Visuals.ChamsSettings.Enabled then

						--// Quad 1 - Front

						Cham.Quad1.Transparency = Environment.Visuals.ChamsSettings.Transparency
						Cham.Quad1.Color = Environment.Visuals.ChamsSettings.Color
						Cham.Quad1.Thickness = Environment.Visuals.ChamsSettings.Thickness
						Cham.Quad1.Filled = Environment.Visuals.ChamsSettings.Filled
						Cham.Quad1.Visible = Environment.Visuals.ChamsSettings.Enabled

						local PosTopLeft = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X,  PartSize.Y, PartSize.Z).Position)
						local PosTopRight = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X,  PartSize.Y, PartSize.Z).Position)
						local PosBottomLeft = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, -PartSize.Y, PartSize.Z).Position)
						local PosBottomRight = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, -PartSize.Y, PartSize.Z).Position)

						Cham.Quad1.PointA = Vector2new(PosTopLeft.X, PosTopLeft.Y)
						Cham.Quad1.PointB = Vector2new(PosBottomLeft.X, PosBottomLeft.Y)
						Cham.Quad1.PointC = Vector2new(PosBottomRight.X, PosBottomRight.Y)
						Cham.Quad1.PointD = Vector2new(PosTopRight.X, PosTopRight.Y)

						--// Quad 2 - Back

						Cham.Quad2.Transparency = Environment.Visuals.ChamsSettings.Transparency
						Cham.Quad2.Color = Environment.Visuals.ChamsSettings.Color
						Cham.Quad2.Thickness = Environment.Visuals.ChamsSettings.Thickness
						Cham.Quad2.Filled = Environment.Visuals.ChamsSettings.Filled
						Cham.Quad2.Visible = Environment.Visuals.ChamsSettings.Enabled

						local PosTopLeft2 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X,  PartSize.Y, -PartSize.Z).Position)
						local PosTopRight2 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X,  PartSize.Y, -PartSize.Z).Position)
						local PosBottomLeft2 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, -PartSize.Y, -PartSize.Z).Position)
						local PosBottomRight2 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, -PartSize.Y, -PartSize.Z).Position)

						Cham.Quad2.PointA = Vector2new(PosTopLeft2.X, PosTopLeft2.Y)
						Cham.Quad2.PointB = Vector2new(PosBottomLeft2.X, PosBottomLeft2.Y)
						Cham.Quad2.PointC = Vector2new(PosBottomRight2.X, PosBottomRight2.Y)
						Cham.Quad2.PointD = Vector2new(PosTopRight2.X, PosTopRight2.Y)

						--// Quad 3 - Top

						Cham.Quad3.Transparency = Environment.Visuals.ChamsSettings.Transparency
						Cham.Quad3.Color = Environment.Visuals.ChamsSettings.Color
						Cham.Quad3.Thickness = Environment.Visuals.ChamsSettings.Thickness
						Cham.Quad3.Filled = Environment.Visuals.ChamsSettings.Filled
						Cham.Quad3.Visible = Environment.Visuals.ChamsSettings.Enabled

						local PosTopLeft3 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X,  PartSize.Y, PartSize.Z).Position)
						local PosTopRight3 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, PartSize.Y, PartSize.Z).Position)
						local PosBottomLeft3 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, PartSize.Y, -PartSize.Z).Position)
						local PosBottomRight3 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, PartSize.Y, -PartSize.Z).Position)

						Cham.Quad3.PointA = Vector2new(PosTopLeft3.X, PosTopLeft3.Y)
						Cham.Quad3.PointB = Vector2new(PosBottomLeft3.X, PosBottomLeft3.Y)
						Cham.Quad3.PointC = Vector2new(PosBottomRight3.X, PosBottomRight3.Y)
						Cham.Quad3.PointD = Vector2new(PosTopRight3.X, PosTopRight3.Y)

						--// Quad 4 - Bottom

						Cham.Quad4.Transparency = Environment.Visuals.ChamsSettings.Transparency
						Cham.Quad4.Color = Environment.Visuals.ChamsSettings.Color
						Cham.Quad4.Thickness = Environment.Visuals.ChamsSettings.Thickness
						Cham.Quad4.Filled = Environment.Visuals.ChamsSettings.Filled
						Cham.Quad4.Visible = Environment.Visuals.ChamsSettings.Enabled

						local PosTopLeft4 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X,  -PartSize.Y, PartSize.Z).Position)
						local PosTopRight4 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, -PartSize.Y, PartSize.Z).Position)
						local PosBottomLeft4 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, -PartSize.Y, -PartSize.Z).Position)
						local PosBottomRight4 = WorldToViewportPoint(CorFrame * CFramenew(-PartSize.X, -PartSize.Y, -PartSize.Z).Position)

						Cham.Quad4.PointA = Vector2new(PosTopLeft4.X, PosTopLeft4.Y)
						Cham.Quad4.PointB = Vector2new(PosBottomLeft4.X, PosBottomLeft4.Y)
						Cham.Quad4.PointC = Vector2new(PosBottomRight4.X, PosBottomRight4.Y)
						Cham.Quad4.PointD = Vector2new(PosTopRight4.X, PosTopRight4.Y)

						--// Quad 5 - Right

						Cham.Quad5.Transparency = Environment.Visuals.ChamsSettings.Transparency
						Cham.Quad5.Color = Environment.Visuals.ChamsSettings.Color
						Cham.Quad5.Thickness = Environment.Visuals.ChamsSettings.Thickness
						Cham.Quad5.Filled = Environment.Visuals.ChamsSettings.Filled
						Cham.Quad5.Visible = Environment.Visuals.ChamsSettings.Enabled

						local PosTopLeft5 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X,  PartSize.Y, PartSize.Z).Position)
						local PosTopRight5 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, PartSize.Y, -PartSize.Z).Position)
						local PosBottomLeft5 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, -PartSize.Y, PartSize.Z).Position)
						local PosBottomRight5 = WorldToViewportPoint(CorFrame * CFramenew(PartSize.X, -PartSize.Y, -PartSize.Z).Position)

						Cham.Quad5.PointA = Vector2new(PosTopLeft5.X, PosTopLeft5.Y)
						Cham.Quad5.PointB = Vector2new(PosBottomLeft5.X, PosBottomLeft5.Y)
						Cham.Quad5.PointC = Vector2new(PosBottomRight5.X, PosBottomRight5.Y)
						Cham.Quad5.PointD = Vector2new(PosTopRight5.X, PosTopRight5.Y)

						--// Quad 6 -
