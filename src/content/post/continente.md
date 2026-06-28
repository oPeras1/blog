---
title: "Abusing Cartão Continente's Memory Game "
description: "In April 2025, I discovered a serious vulnerability in the Cartão Continente app's memory game feature. After responsibly disclosing it to MC Sonae, their response was... boring. Here's how I found it, what I did, and why it's now time to publicly share this."
publishDate: "08 Aug 2025"
tags: ["security", "vulnerability-disclosure", "api"]
---

Back in April 2025, I was casually playing a game on the Cartão Continente app, the rewards app from Continente, one of Portugal's biggest retail brands under the Sonae group, when I noticed something unusual.

### What I Was Doing

I was messing around with their memory game, part of a limited-time points campaign. At first, I was just trying to save some euros because... why not? But as someone who loves poking around HTTP traffic and APIs, I started looking deeper... and what I found was alarming.

My curiosity kicked in, and I started to inspect how the app handled point submissions. So I fired up a proxy (Burp Suite, for the curious) and started capturing the requests the app sent when finishing a game.

One endpoint in particular caught my attention:

```text
https://cartaocontinente.pt/CartaoContinente/screenservices/CartaoContinente_Gaming_CW/MemoryGame/MemoryGame_Main/ActionEnd_MG_Game
```

There was no CAPTCHA. No session or game ID validation. No server-side verification of the game actually being played. Just a simple JSON request claiming I played and won the game, with full control over flips, duration, game log... everything.

So naturally, I tested what would happen if I just... replayed that same request. And sure enough, points started stacking.

### Proof of Concept: Spam Curl Requests

With just CURL, I could easily automate it. Here's a simplified version of what I ran, repeatedly:

```bash
curl -X POST https://cartaocontinente.pt/... -H "Cookie: [session]" -H "x-csrftoken: [...]" -H "Content-Type: application/json" -d '{"inputParameters":{"Flips":10,"Duration":"14.75"}}'
```

It worked like a charm. I racked up between 1500-2000 points in just 2-3 seconds, just by looping that one request. To confirm it wasn't just visual, I redeemed 50 of those points for a 20% discount voucher on "Panrico bread," because... I am a good person (I could have traded it for a 1€ voucher :omegalul:). I just didn't want to abuse it, because I planned to report the vulnerability later to the MC Sonae team.

### The Impact

* Unlimited reward points for minimal effort
* Direct financial loss to MC Sonae (if abused at scale)
* No rate-limiting or fraud detection mechanisms in place
* Potential for bot exploitation, especially during similar future campaigns

The thing is that it wasn't just a UI bug or some visual validation issue, it had real economic impact potential for MC Sonae, and they didn't seem to take it seriously...

### Reporting It

I responsibly reported the issue on **April 19, 2025** to their official disclosure email (`rvd@mc.pt`), as per their [Responsible Disclosure policy](https://mc.sonae.pt/en/responsible-disclosure-of-vulnerabilities/). I fully disclosed every detail, even more than what I wrote here, because, after all, I don't want people to take advantage of it. (And no, it won't work out of the box, it's a bit more tricky to make and read these kinds of requests on a phone.)

### The Answer

Five days later (quite fast, actually), I got a polite but vague reply:

> We have confirmed the existence of the described vulnerability. The responsible department is currently monitoring it... We will provide feedback in due course.

And that was it. Nothing else. It's been well over 90 days now (the window after which public disclosure is acceptable) and I haven't heard anything back.

No follow-up. No patch confirmation. No further acknowledgment (not even a simple "thanks").

### So… Now What?

I waited patiently, gave them plenty of time to look into it, and... radio silence. Honestly, I don't even know if they fixed it, and at this point, I don't really care. For my first vulnerability disclosure, the experience was a bit of a letdown.

It’s just wild to me that companies still leave marketing minigames completely wide open. Security shouldn't stop at the login screen. If a feature can be exploited to print free reward points or extract value, it needs server-side validation. Period.

I didn’t expect a massive payout or anything, but a basic "thanks for looking out" goes a long way. Ghosting the people who responsibly report bugs in your system is just a bad look.

---

**Author:** Hugo Pereira  
**Email:** me@operas.pt