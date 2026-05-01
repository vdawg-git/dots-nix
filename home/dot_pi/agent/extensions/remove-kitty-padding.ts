   import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

   const isKitty = !!process.env.KITTY_WINDOW_ID;

   export default function (pi: ExtensionAPI) {
      if (!isKitty) return;

      pi.on("session_start", async (_event, _ctx) => {
         await pi.exec("kitty", ["@", "set-spacing", "padding=0", "margin=0"]);
      });

      pi.on("session_shutdown", async (event, _ctx) => {
         // Only restore padding when actually quitting pi, not on /reload or session switches
         if (event.reason === "quit") {
            await pi.exec("kitty", ["@", "set-spacing", "padding=24", "margin=0"]);
         }
      });
   }
