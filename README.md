# DarkSoulsDeathScreen (1.12 version)

Original: http://www.wowace.com/addons/dark-souls-death-screen/

**[Demo](https://gitgud.io/SweedJesus/DarkSoulsDeathScreen_1.12/raw/master/dsds.webm)**

This addon is vanilla compatible version of the addon [Dark Souls Death
Screen][dsds] by [latreese][latreese] (idea goes to him). This came as an
anonymous request on /nogs/, and I took up the challenge.

### **>> Rename the folder to `DSDS`<<**

-   Player death triggers the YOU DIED animation.
    -   Hunter Feign Death does trigger the animation, and priest Spirit of
        Redemption sets a false death flag that's checked the the aura is lost,
        triggering the animation then.
-   Type `/dsds` in chat for standard Ace2 addon commands and...
    -   `/dsds test` to trigger the YOU DIED animation.
-   This is not an extensible addon, so don't expect any more features without
    work; work that I'm probably too lazy to put do.

## Major Challenges:

-   **Vanilla WoW has none of the animation framework used by the retail
    addon**, making a straight "backport" unfeasable without completely
    implementing those missing frameworks.
-   ...so instead I hacked together some timer-driven "animations" using the
    Ace2 library [Metrognome][metrognome].

[dsds]:http://www.wowace.com/addons/dark-souls-death-screen/
[latreese]:http://www.wowace.com/profiles/latreese/
[metrognome]:https://web.archive.org/web/20070729015742/http://www.wowace.com/wiki/Metrognome
