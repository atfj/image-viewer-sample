ImagePreviewSample
---
This is a sample to search for images and display an image preview.

## Environment
- Xcode 16.4
- Swift 5
- Minimum iOS version: 17.0

## Prerequisites
Before running the project, you need to have the xcconfig file in the root of the project. This project uses Pixels API to search for images.

** Development.xcconfig **
```
API_BASE_URL = https:/$()/<your_api_base_url>
API_KEY      = <your_api_key>
```

## Usage
1. Open the project in Xcode.
2. Run the project.
3. Search for an image.
4. Select an image.
5. The image preview will be displayed.
6. The preview can be zoomed in and out if needed.

## Notes
- Unit tests are covered.
- Zooming in, out and dragging during zooming are supported an an additional feature.
- The photo preview screen is shown as a full screen modal.
- Used AI tools
    - Chat GPT o4-mini-high
    - Claude 4 sonnet
- Working time: Around 20 hours

## Reference
- https://github.com/line/line-sdk-ios-swift/tree/master/LineSDK/LineSDK/Networking/Client