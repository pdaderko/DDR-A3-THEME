local pn = ...

return Def.ActorFrame{
	Def.Sprite{
		InitCommand=function(self)
			if #(GAMESTATE:GetHumanPlayers()) == 2 then
				if pn == PLAYER_1 then
					self:cropright(0.5);
				elseif pn == PLAYER_2 then
					self:cropleft(0.5);
				end;
			end;
		end;
		SetCommand=function(self,param)
			if not GAMESTATE:IsCourseMode() then
				self.cur_song = param.Song;
				self:queuecommand "DiffChange";
			end
		end;
		DiffChangeCommand=function(self)
			local st = GAMESTATE:GetCurrentStyle():GetStepsType();
			local diff = GAMESTATE:GetCurrentSteps(pn):GetDifficulty();
			if self.cur_song then
				if self.cur_song:HasStepsTypeAndDifficulty(st,diff) then
					local steps = self.cur_song:GetOneSteps( st, diff );
					local profile
					if PROFILEMAN:IsPersistentProfile(pn) then
						profile = PROFILEMAN:GetProfile(pn);
					else
						profile = PROFILEMAN:GetMachineProfile();
					end;
					local scorelist = profile:GetHighScoreList(self.cur_song,steps);
					assert(scorelist);
					local scores = scorelist:GetHighScores();
					assert(scores);
					local currscore=0;
					local bestmark=0
					self:visible(false) --default no lamp
					for i=1, #scores do --loop over all scores, updating the lamp corresponding to the best mark (not always highest score)
						if scores[i] then
							currscore = scores[i];
							assert(currscore);
							local misses = currscore:GetTapNoteScore("TapNoteScore_Miss")
										  +currscore:GetTapNoteScore("TapNoteScore_CheckpointMiss")
										  +currscore:GetTapNoteScore("TapNoteScore_HitMine")
										  +currscore:GetTapNoteScore("TapNoteScore_W5")
										  +currscore:GetHoldNoteScore("HoldNoteScore_MissedHold")
										  +currscore:GetHoldNoteScore("HoldNoteScore_LetGo")
							local goods = currscore:GetTapNoteScore("TapNoteScore_W4")
							local greats = currscore:GetTapNoteScore("TapNoteScore_W3")
							local perfects = currscore:GetTapNoteScore("TapNoteScore_W2")
							local marvelous = currscore:GetTapNoteScore("TapNoteScore_W1")
							local hasUsedBattery = string.find(currscore:GetModifiers(),"Lives")
							if (misses) == 0 and scores[i]:GetScore() > 0 and (marvelous+perfects)>0 then
								if (greats+perfects) == 0 then
									if bestmark<7 then
										bestmark=7
										self:Load(THEME:GetPathG("MusicWheelItem Song NormalPart/lamp/ClearedMark","MFC"))
										self:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.75")):effectperiod(0.1)
									end
								elseif greats == 0 then
									if bestmark<6 then
										bestmark=6
										self:Load(THEME:GetPathG("MusicWheelItem Song NormalPart/lamp/ClearedMark","PFC"))
										self:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.75")):effectperiod(0.1)
									end
								elseif (misses+goods) == 0 then
									if bestmark<5 then
										bestmark=5
										self:Load(THEME:GetPathG("MusicWheelItem Song NormalPart/lamp/ClearedMark","GreatFC"))
										self:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.75")):effectperiod(0.1)
									end
								elseif (misses) == 0 then
									if bestmark<4 then
										bestmark=4
										self:Load(THEME:GetPathG("MusicWheelItem Song NormalPart/lamp/ClearedMark","GoodFC"))
										self:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,0.75")):effectperiod(0.1)
									end
								end;
								self:visible(true)
							else
								if currscore:GetGrade() ~= 'Grade_Failed' then
									if hasUsedBattery then
										if bestmark<3 then
											bestmark=3
											self:visible(true)
											self:Load(THEME:GetPathG("MusicWheelItem Song NormalPart/lamp/ClearedMark","Risky"))
											self:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,1")):effectperiod(1.1)
										end
									else
										if bestmark<2 then
											bestmark=2
											self:visible(true)
											self:Load(THEME:GetPathG("MusicWheelItem Song NormalPart/lamp/ClearedMark","LifeBar"))
											self:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,1")):effectperiod(1.1)
										end
									end
								else
									if bestmark<1 then
										bestmark=1
										self:visible(true)
										self:Load(THEME:GetPathG("MusicWheelItem Song NormalPart/lamp/ClearedMark","Failed"))
										self:diffuseshift():effectcolor1(color("1,1,1,1")):effectcolor2(color("1,1,1,1")):effectperiod(1.1)
									end
								end
							end;
						else
							self:visible(false)
						end;
					end;
				else
					self:visible(false)
				end;
			else
				self:visible(false)
			end;
		end;
	};
};
