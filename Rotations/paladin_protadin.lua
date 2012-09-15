--tank
function paladin_protadin(self)
   -- OH GOD THIS IS GOING TO BE TERRIBLE
   -- jpganis
   -- noxxic.com
   local hPower = UnitPower("player","9")

   local spellTable =
   {
	   --buffs
	   { "Seal of Truth", not jps.buff("Seal of Truth") },
	   { "Righteous Fury", not jps.buff("Righteous Fury") },
	   { "sacred shield", not jps.buff("Sacred Shield") },

	   --self cds
	   { "lay on hands", jps.hp() < 0.2 },
	   { "avenging wrath" },
	   { "holy avenger" },

	   --holy power use
	   { "shield of the righteous" },
	   { "word of glory", jps.hp() < 0.7 },

	   --aoe
	   { "hammer of the righteous", jps.MultiTarget },
	   { "consecration", jps.MultiTarget },
	   { "holy wrath", jps.MultiTarget },

	   --single target tanking 
	   { "crusader strike" },
	   { "judgment" },
	   { "avenger's shield" },
	   { "hammer of wrath" },
	   { "consecration" },
	   { "holy wrath" },
   }

end
