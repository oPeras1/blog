---
title: "Abusing Cartão Continente's Memory Game"
description: "In April 2025, I found a way to farm unlimited reward points from Continente's mobile game campaign. I reported it responsibly, waited over 90 days, and heard almost nothing back. Here's the story."
publishDate: "08 Aug 2025"
tags: ["security", "vulnerability-disclosure", "api"]
coverImage:
  src: "continente.jpg"
  alt: "Screenshot of the memory game"
readingTime: 4
---

Just like a lot of people in Portugal, I have the Cartão Continente app on my phone. It's the loyalty app for Continente, one of the country's biggest supermarket chains, part of the Sonae group. Back in April 2025, they were running a limited-time campaign with a little memory-matching minigame bolted onto the app: match the tiles, win some extra points, redeem them for discounts. Harmless stuff.

I was playing it mostly to shave a few euros off my grocery bill. But at some point the security researcher instinct kicked in, and I started wondering: what's actually happening on the wire when I finish a round?

## Poking at the Traffic

I fired up Burp Suite and pointed my phone's traffic through it, then played a round of the game like normal. One request stood out immediately, it fired the moment the game ended, and it was clearly the one telling the backend "I won, give me points."

The endpoint looked something like this:

```text
https://cartaocontinente.pt/CartaoContinente/screenservices/CartaoContinente_Gaming_CW/MemoryGame/MemoryGame_Main/ActionEnd_MG_Game
```

I looked at the request body a little closer, expecting to see some kind of session token tying it to a specific game instance, maybe a signed payload, something server-side that would make this hard to forge. Instead, what I found was a plain JSON body describing the result of the game: how many flips I made, how long it took, and nothing else. No per-game ID. No CAPTCHA. No signature. Nothing stopping me from just... describing a game I never played.

So I tried the obvious thing: I replayed the exact same request.

It worked. The points landed in my account like I'd actually played and won.

## Confirming It Wasn't a Fluke

At that point I wanted to know how far this actually went, so I stripped the request down to something I could fire from the command line with curl, using the session cookies and CSRF token from my own logged-in session:

```bash
curl -X POST https://cartaocontinente.pt/... \
  -H "Cookie: [session]" \
  -H "x-csrftoken: [...]" \
  -H "Content-Type: application/json" \
  -d '{"inputParameters":{"Flips":10,"Duration":"14.75"}}'
```

Then I just looped it.

Points started stacking almost instantly, no delay, no throttling, no "you already played today" wall. In two or three seconds I'd racked up somewhere between 1,500 and 2,000 points, just from firing the same "I won" claim over and over with nothing behind it.

To make sure this wasn't a display glitch (points showing in some cached counter without actually being redeemable) I cashed in 50 of them for a 20% discount voucher on a loaf of bread. It worked. The voucher was real. (I could have gone bigger, there was a 1€ voucher tier sitting right there, but I didn't want to actually profit from a bug I was planning to report.)

## Why This Actually Mattered

This wasn't a cosmetic bug or a UI quirk. The game's outcome was decided entirely client-side, and the server just trusted whatever the client told it. That has a few uncomfortable implications:

- Anyone could generate effectively unlimited reward points for almost no effort
- At scale, that's a direct financial cost to MC Sonae, every point redeemed is a discount they're eating
- There was no rate limiting or anomaly detection catching thousands of fake "wins" from one account
- During a live campaign, this is exactly the kind of endpoint that gets found and quietly farmed by bots, not researchers

Marketing minigames tend to get treated as low-stakes because they're "just for fun," but the moment a game can be converted into real discounts or money, it needs the same server-side scrutiny as any other transaction.

## Reporting It

I sent a full write-up to Sonae's disclosure address (`rvd@mc.pt`) on **April 19, 2025**, following their [Responsible Disclosure policy](https://mc.sonae.pt/en/responsible-disclosure-of-vulnerabilities/). I included more detail than I'm sharing here on purpose. I wanted them to be able to fix it properly, not just make it slightly harder to notice.

Five days later, I got a reply:

> We have confirmed the existence of the described vulnerability. The responsible department is currently monitoring it... We will provide feedback in due course.

And then nothing. No patch confirmation, no follow-up, no acknowledgment beyond that one message. It's now been well over 90 days, past the window most responsible disclosure policies, including theirs, treat as the point where public write-ups become fair game, and I haven't heard anything since.

## Where That Leaves Things

I don't know if it's fixed. I haven't gone back to check, and at this point I'm not particularly motivated to. What I do know is that a company running a loyalty program with real financial value attached had a game endpoint that would accept a claimed win with zero server-side verification, and when someone told them about it responsibly, the response was a single templated email.

That's the part that actually bugs me, more than the vulnerability itself. I wasn't expecting a bounty. A short "thanks, we fixed it" would have been enough. Ghosting the people who report issues instead of exploiting them is a bad look, and it's the kind of thing that quietly discourages the next person from bothering to report at all.

---

**Author:** Hugo Pereira
**Email:** me@operas.pt