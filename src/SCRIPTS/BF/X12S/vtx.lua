
return {
    read           = 88, -- MSP_VTX_CONFIG
    write          = 89, -- MSP_VTX_SET_CONFIG
    eepromWrite    = true,
    reboot         = false,
    saveMaxRetries = 2,
    saveTimeout    = 300, -- 3s
    title          = "VTX",
    minBytes       = 5,
    text= {
        { t = "Band",    x = 50,   y = 130,  to = SMLSIZE },
        { t = "Channel", x = 50,   y = 175,  to = SMLSIZE },
        { t = "Power",   x = 240,  y = 130,  to = SMLSIZE },
        { t = "Pit",     x = 240,  y = 175,  to = SMLSIZE },
        { t = "Proto",   x = 50,   y = 65,   to = SMLSIZE },
        { t = "Freq",    x = 240,  y = 65,   to = SMLSIZE },
    },
    fields = {
        { x = 140,  y =  115, min=1, max=5, vals = { 2 }, to = DBLSIZE, table = { "A", "B", "E", "F", "R" }, upd = function(self) self.updateVTXFreq(self) end },
        { x = 140,  y =  160, min=1, max=8, vals = { 3 }, to = DBLSIZE, upd =  function(self) self.updateVTXFreq(self) end },
        { x = 330,  y = 115,  min=1, vals = { 4 }, to = DBLSIZE, upd = function(self) self.updatePowerTable(self) end },
        { x = 330,  y = 160,  min=0, max=1, vals = { 5 }, to = DBLSIZE, table = { [0]="OFF", "ON" } },
        { x = 120,  y =  65,  write = false, ro = true, vals = { 1 }, to = SMLSIZE, table = {[3]="SmartAudio",[4]="Tramp",[255]="None"} },
        { x = 330,  y =  50,  min=5000, max=6000, to = DBLSIZE, ro=true },
    },
    freqLookup = {
        { 5865, 5845, 5825, 5805, 5785, 5765, 5745, 5725 }, -- Boscam A
        { 5733, 5752, 5771, 5790, 5809, 5828, 5847, 5866 }, -- Boscam B
        { 5705, 5685, 5665, 5645, 5885, 5905, 5925, 5945 }, -- Boscam E
        { 5740, 5760, 5780, 5800, 5820, 5840, 5860, 5880 }, -- FatShark
        { 5658, 5695, 5732, 5769, 5806, 5843, 5880, 5917 }, -- RaceBand
    },
    postLoad = function (self)
        if self.values[2] == 0 or self.values[3] == 0 or self.values[4] == 0 then
            self.values = {}
        end
    end,
    preSave = function(self)
        local valsTemp = {}
        local channel = (self.values[2]-1)*8 + self.values[3]-1
        valsTemp[1] = bit32.band(channel,0xFF)
        valsTemp[2] = bit32.rshift(channel,8)
        valsTemp[3] = self.values[4]
        valsTemp[4] = self.values[5]
        return valsTemp
    end,
    updatePowerTable = function(self)
        if self.values and not self.fields[3].table then
            if self.values[1] == 3 then
                self.fields[3].table = { 25, 200, 500, 800 }
                self.fields[3].max = 4
            elseif self.values[1] == 4 then
                self.fields[3].table = { 25, 100, 200, 400, 600 }
                self.fields[3].max = 5
            end
        end
    end,
    updateVTXFreq = function(self)
        if (#(self.values) or 0) >= self.minBytes then
            if (self.fields[2].value or 0) > 0 and (self.fields[3].value or 0) > 0 then
                self.fields[6].value = self.freqLookup[self.values[2]][self.values[3]]
            end
        end
    end
}
