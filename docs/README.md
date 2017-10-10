Use jekyll to generate the iOS documentation

# Installation

```
gem install jekyll bundler
```

# Fetch the iOS github wiki submodule
git submodule init
git submodule update

# Generate the documentation and test on local (should be executed on the docs directory)
```
bundle exec jekyll serve
```

Navigate to http://127.0.0.1:4000

# Notice

Files are generated into _site folder