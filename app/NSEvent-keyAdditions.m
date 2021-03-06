/*
 * Copyright (c) 2008-2012 Martin Hedenfalk <martin@vicoapp.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NSEvent-keyAdditions.h"
#include "logging.h"

/* I just wanted the Events.h header! */
#import <Carbon/Carbon.h>

@implementation NSEvent (keyAdditions)

- (NSInteger)normalizedKeyCode
{
	// http://sigpipe.macromates.com/2005/09/24/deciphering-an-nsevent/
	// given theEvent (NSEvent*) figure out what key
	// and modifiers we actually want to look at,
	// to compare it with a menu key description

	NSUInteger quals = [self modifierFlags];

	NSString *str = [self characters];
	NSString *strWithout = [self charactersIgnoringModifiers];

	DEBUG(@"length = %lu / %lu", [str length], [strWithout length]);
	if ([str length] == 0) {
		/*
		 * This is not a complete key. Could be a dead key or some
		 * non-western input method thingy.
		 */
		return -1;
	}

	unichar ch = [str length] ? [str characterAtIndex:0] : 0;
	unichar key = ch;
	unichar without = [strWithout length] ? [strWithout characterAtIndex:0] : 0;
	unsigned short keycode = [self keyCode];

	DEBUG(@"decoding event %@", self);
	DEBUG(@"ch = 0x%02x, without = 0x%02x, keycode = 0x%02x, flags = 0x%08x => s=%s, c=%s, a=%s, C=%s ",
	    ch, without, keycode, quals,
	    (quals & NSShiftKeyMask) ? "YES" : "NO",
	    (quals & NSControlKeyMask) ? "YES" : "NO",
	    (quals & NSAlternateKeyMask) ? "YES" : "NO",
	    (quals & NSCommandKeyMask) ? "YES" : "NO"
	);

	if (ch == 0x19 && keycode == kVK_Tab) {
		/* apparently shift-control-tab sends a ctrl-y on my keyboard */
		without = 0x09;
	}

	if (!(quals & NSNumericPadKeyMask)) {
		if ((quals & NSControlKeyMask)) {
			/* Remove shift if it was used to generate a ctrl-[\]^_ */
			if (key >= 0x1B && key < 0x20 &&
			    (quals & NSDeviceIndependentModifierFlagsMask) == (NSControlKeyMask | NSShiftKeyMask))
				quals &= ~NSShiftKeyMask;

			if (key < 0x20 && ((key != 0x1B && key != 0x0D && key != 0x09 && key != 0x19) || key != without) &&
			    (quals & NSDeviceIndependentModifierFlagsMask) == NSControlKeyMask)
				/* only control pressed */
				quals = 0;
			else
				key = without;
		} else if (quals & NSAlternateKeyMask) {
			if (0x20 < key && key < 0x7f && key != without)
				quals &= ~NSAlternateKeyMask;
			else
				key = without;
		} else if ((quals & (NSCommandKeyMask | NSShiftKeyMask)) == (NSCommandKeyMask | NSShiftKeyMask))
			key = without;

		if ((0x20 < key && key < 0x7f) || key == 0x1E)
			quals &= ~NSShiftKeyMask;
	}

	if (key > 0 && key < 0x20 && key != 0x1B && key != 0x0D && key != 0x09)
		quals &= ~NSControlKeyMask;

	unsigned int modifiers = quals & (NSShiftKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask);

	NSInteger enc = (modifiers | key);
	DEBUG(@"key = %C (0x%04x / 0x%04x -> 0x%04x), s=%s, c=%s, a=%s, C=%s => 0x%04x",
	    key ?: ' ', ch, without, key,
	    (modifiers & NSShiftKeyMask) ? "YES" : "NO",
	    (modifiers & NSControlKeyMask) ? "YES" : "NO",
	    (modifiers & NSAlternateKeyMask) ? "YES" : "NO",
	    (modifiers & NSCommandKeyMask) ? "YES" : "NO",
	    enc
	);

	return enc;
}

@end
