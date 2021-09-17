# WikiDevice: the asynchronous library that gives you the answer from theiphonewiki
the asynchronous library that gives you the answer from theiphonewiki

A crazy little experiment for automation fans like me. I made this algorithm that reads the identification code of the device, physical or simulated, 
and load the theiphonewiki page to extrapolate the model name based on the identification code (example iPhone11,2 -> iPhone XS). 
The algorithm interfaces with the WIKI page using the internal Wiki API Sandbox tool that allows you to have a JSON response, however the content is not 
obtainable in JSON (just the part that was needed, that is the wikitables) so I parsed the HTML content to get to the device name, without using 
third parts HTML parsing libraries.

PROS: always updated, you don't need to add new devices

CONS: asyncronous answer using the wiki page from web

P.S. Feel free to improve my code to get an even more precise result and a more elegant syntax 
P.S.S. If you need a more immediate answer use my previous answer here in this page

# Usage:
```
var deviceModel:String = ""
WikiDevice.model { (model) in
     print("Using WikiDevice, running on: \(model)")
     deviceModel = model
}
```

# Output:
Using WikiDevice, running on: iPhone 11 Pro Max

You can find more details to my Stack Overflow answer: https://stackoverflow.com/a/69225035/1894067
