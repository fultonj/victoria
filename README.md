# Victoria

Every OpenStack cycle I end up with scripts I revise to make
development easier. This is where I'm storing the scripts for the
Victoria cycle.

## How I use

- Use [tripleo-lab overrides](tripleo-lab) to deploy an undercloud
- Run the following on undercloud initialize it for work
```
git clone git@github.com:fultonj/victoria.git
pushd victoria/init
./git-init.sh tht
popd
```
- Deploy using [standard](standard) or [tripleo-cephadm][tripleo-cephadm].
