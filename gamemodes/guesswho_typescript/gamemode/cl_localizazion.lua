--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
-- Lua Library inline imports
__TS__Index = function(classProto)
    return function(tbl, key)
        local proto = classProto;
        while true do
            local val = rawget(proto, key);
            if val ~= nil then
                return val;
            end
            local getters = rawget(proto, "____getters");
            if getters then
                local getter = getters[key];
                if getter then
                    return getter(tbl);
                end
            end
            local base = rawget(rawget(proto, "constructor"), "____super");
            if not base then
                break;
            end
            proto = rawget(base, "prototype");
        end
    end;
end;

__TS__NewIndex = function(classProto)
    return function(tbl, key, val)
        local proto = classProto;
        while true do
            local setters = rawget(proto, "____setters");
            if setters then
                local setter = setters[key];
                if setter then
                    setter(tbl, val);
                    return;
                end
            end
            local base = rawget(rawget(proto, "constructor"), "____super");
            if not base then
                break;
            end
            proto = rawget(base, "prototype");
        end
        rawset(tbl, key, val);
    end;
end;

GWLocalization = GWLocalization or {};
GWLocalization.__index = GWLocalization;
GWLocalization.prototype = GWLocalization.prototype or {};
GWLocalization.prototype.____getters = {};
GWLocalization.prototype.__index = __TS__Index(GWLocalization.prototype);
GWLocalization.prototype.____setters = {};
GWLocalization.prototype.__newindex = __TS__NewIndex(GWLocalization.prototype);
GWLocalization.prototype.constructor = GWLocalization;
GWLocalization.new = function(...)
    local self = setmetatable({}, GWLocalization.prototype);
    self:____constructor(...);
    return self;
end;
GWLocalization.prototype.____constructor = function(self)
    self.defaultLocale = "en";
    self.currentLocale = self.defaultLocale;
end;
GWLocalization.prototype.____getters.CurrentLocale = function(self)
    return self.currentLocale;
end;
GWLocalization.prototype.____setters.CurrentLocale = function(self, newLocale)
    if self:IsLocale(newLocale) then
        self.currentLocale = newLocale;
    end
end;
GWLocalization.prototype.IsLocale = function(self, locale)
    return self.locales[locale] ~= nil;
end;
GWLocalization.prototype.Translate = function(self, token)
    return (self.locales[self.currentLocale][token] or self.locales[self.defaultLocale][token]) or token;
end;
GWLocalization.prototype.AddLanguage = function(self, locale, langTbl)
    self.locales[locale] = langTbl;
end;
GWLocalization.prototype.GetLocaleList = function(self)
    return table.GetKeys(self.locales);
end;
GWLocalization.GetInstance = function(self)
    if not GWLocalization.instance then
        GWLocalization.instance = GWLocalization.new();
    end
    return GWLocalization.instance;
end;
