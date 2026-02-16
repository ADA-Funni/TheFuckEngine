package funkin.memory;

import openfl.system.System;

class Memory {
	private static var memMax:Float = 0.0;

	public static inline function getPeakUsage():Float
		return memMax;

	public static inline function getCurrentUsage():Float {
		var mem = System.totalMemory;
		if (mem > memMax) memMax = mem;
		return mem;
	}
}