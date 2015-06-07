# Polymerize for Meteor [![Build Status](https://travis-ci.org/loneleeandroo/meteor-polymerize.svg)](https://travis-ci.org/loneleeandroo/meteor-polymerize)
Synthesises Polymer and Meteor.

The purpose of this package is to make it incredibly easy to use Polymer in a Meteor project, as if Polymer was made for Meteor.
All best practices of integrating Polymer with Meteor should be included as default and require no user action, however the user
should be able to override any options easily as well.

## Warning
Not production ready. This project is still in prototyping phase. Any API may be subject to change.

## Features
As of version <code>0.2.0</code>, Polymerize supports the following features:
* Add elements using <code>bower install --save</code>
* Automatically imports elements based on the main entry of the <code>bower.json</code>
* Delays Blaze.render until after WebComponentsReady is fired.
* Vulcanizing imports when doing a production build or when the environmental variable <code>VULCANIZE</code> is set to true.

## Installation
You can add Polymerize to your project via:
```
meteor add loneleeandroo:polymerize
```
#### Comments
##### bower.json
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
##### .bowerrc
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

The element will be imported into your project automatically. There is no need to manually add a <code>link</code> import to the <code>head</code> of the document. 
<code>Polymerize</code> will look at the main entry of the <code>bower.json</code>in the bower component's folder to figure out which HTML file to import. 
If you need to manually specify which HTML file to import please use the override entry of the <code>bower.json</code> in the root of your project directory. [See comments below](#overriding-main-file) on how to create an override entry.
The override entry accepts an array, and will load in the order of the array.

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

##### Vulcanize
Polymer elements are automatically vulcanized when building or running your meteor app as production. <code>Polymerize</code> will look at <code>process.env.NODE_ENV</code>. 
If you want want to vulcanize your elements in development, you can pass the environment variable <code>VULCANIZE</code> before your meteor commands. For example:
```
VULCANIZE=true meteor
```

## Roadmap
* Write TinyTests for the package.
* Implement an easy workflow for creating custom elements and using the Polymer API.
* Look at ways to implement Server Side Rendering for Polymer elements. 
