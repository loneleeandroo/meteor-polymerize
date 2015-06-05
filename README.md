# Polymerize for Meteor [![Build Status](https://travis-ci.org/loneleeandroo/meteor-polymerize.svg)](https://travis-ci.org/loneleeandroo/meteor-polymerize)
Synthesises Polymer and Meteor.

## Warning
Not production ready. This project is still in prototyping phase. Any API may be subject to change.

## Install
You can add Polymerize to your project via:
```
meteor add loneleeandroo:polymerize
```
#### Comments
##### <code>bower.json</code> 
If a <code>bower.json</code> file does not exist in your project root directory, this default <code>bower.json</code> will be created:
```
{
  "name": "my-app",
  "private": true,
  "dependencies": {
    "webcomponentsjs": "^0.7.2",
    "polymer": "Polymer/polymer#^1.0.0"
  },
  "overrides": {
    "webcomponentsjs": {
      "main": [
        "webcomponents-lite.js"
      ]
    }
  }
}
```
##### <code>.bowerrc</code> 
If a <code>.bowerrc</code> file does not exist in your project root directory, this default <code>.bowerrc</code> will be created:
```
{
  "directory": "public/bower_components"
}
```
If you already have a <code>.bowerrc</code>, you will need to change the directory to <code>public/bower_components</code>. This is because the polymer elements requires other files besides the main html import to be available to the client. Currently, placing in the public folder is the most convenient location because it makes files available to the client when building for development and production environments. However, [it may cause longer reload times](https://github.com/meteor/meteor/issues/3373#issuecomment-68172647).

## Usage
### Adding Elements
You can add any elements to your project via the <code>bower install --save</code> command. For example:
```
bower install --save PolymerElements/paper-button#^1.0.0
```

You can browse [the catalog of elements](https://elements.polymer-project.org/) to find the commands for adding the elements you want.

#### Comments
##### Load Order
Elements are imported in the order which they appear in the <code>bower.json</code> dependencies. It is preferrable to leave <code>webcomponentjs</code> and <code>polymer</code> as the first components to load.

##### Overriding main file
Unfortunately, there is inconsistency with the main entry in many of the polymer element's <code>bower.json</code>. Some are expressed as arrays, some are strings and some are null. Luckily, <code>Polymerize</code> handles loading the correct main file. However, if you want more control over the process, you are able to [override the main entry in the <code>bower.json</code>](https://github.com/mquandalle/meteor-bower/pull/54). For example:
```
{
  "name": "my-app",
  "private": true,
  "dependencies": {
    "webcomponentsjs": "^0.7.2",
    "polymer": "Polymer/polymer#^1.0.0"
  },
  "overrides": {
    "webcomponentsjs": {
      "main": [
        "webcomponents-lite.js"
      ]
    },
    "polymer": {
      "main": [
        "polymer-micro.html"
      ]
    }
  }
}
```

##### Blaze.render
Some polymer elements, such as <code>iron-icon</code>, requires "WebComponentsReady" to be fired before being rendered properly by Blaze on certain browsers, namely Chrome. So <code>Polymerize</code> will disable the Blaze.render function until after the "WebComponentsReady" event has been fired.

## Roadmap
TODO
