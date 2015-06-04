Package.describe({
  name: 'loneleeandroo:polymerize',
  version: '0.1.1',
  summary: 'Synthesises Polymer and Meteor',
  git: 'git@github.com:loneleeandroo/meteor-polymerize.git',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('METEOR@1.0');
  
  api.use([
    'coffeescript',
    'underscore',
    'mquandalle:bower@1.4.1',
    'meteorhacks:inject-initial@1.0.2'
  ]);

  api.imply('mquandalle:bower@1.4.1')

  api.addFiles('polymerize.coffee', 'server');
});

// TODO: Add Vulcanize to production builds.
Npm.depends({
  vulcanize: "1.8.1"
});
