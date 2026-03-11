const LAUNCHER_URL = chrome.runtime.getURL("launcher.html");

function buildLauncherUrl() {
  return `${LAUNCHER_URL}?launch=${Date.now()}`;
}

async function findExistingAtlasTab() {
  const tabs = await chrome.tabs.query({});

  return tabs.find((tab) => {
    const candidates = [tab.url, tab.pendingUrl].filter(Boolean);

    return candidates.some((url) => url.startsWith(LAUNCHER_URL));
  });
}

chrome.action.onClicked.addListener(async () => {
  const existingTab = await findExistingAtlasTab();

  if (existingTab?.id) {
    await chrome.tabs.update(existingTab.id, {
      active: true,
      url: buildLauncherUrl(),
    });

    if (existingTab.windowId) {
      await chrome.windows.update(existingTab.windowId, { focused: true });
    }

    return;
  }

  await chrome.tabs.create({ url: buildLauncherUrl() });
});
