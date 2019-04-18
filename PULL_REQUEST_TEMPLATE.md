Before submitting your PR, please review the following checklist :

## If you are adding a framework

+ [ ] Does a `info.yml` file exist in your directory?
+ [ ] Does a `Dockerfile` exists?
+ [ ] Do all tests pass?
~~~
export FRAMEWORK=<MY_FRAMEWORK>
build.rb ${FRAMEWORK}
rspec spec.rb
~~~
