Package.describe({
  name: 'loneleeandroo:polymerize',
  version: '0.1.2',
  summary: 'Synthesises Polymer and Meteor',
  git: 'https://github.com/loneleeandroo/meteor-polymerize',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@1.0');
  
  api.use([
    'coffeescript',
    'underscore',
    'reactive-var',
    'mquandalle:bower@1.4.1',
    'meteorhacks:inject-initial@1.0.2'
  ]);

  api.imply('mquandalle:bower@1.4.1')

  api.addFiles('polymerize-client.coffee', 'client');
  api.addFiles('polymerize-server.coffee', 'server');
});

// TODO: Add Vulcanize to production builds.
Npm.depends({
  vulcanize: "1.8.1"
});
