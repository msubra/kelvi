chrome.app.runtime.onLaunched.addListener(function() {
  chrome.app.window.create('kelvi.html', {
    'bounds': {
      'width': 1920,
      'height': 1080
    }
  });
});