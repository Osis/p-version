## p-version

*p-version* is a ruby gem that is used to assist in managing versions for Pivotal CF products/components that are deployed via Ops Manager.

### usage

To bump the product version from 1.2.3.4-alpha2 to 1.2.3.4-alpha3, run the following command:

```
bundle
bundle exec bump_alpha_version --product-dir ~/workspace/p-product/
```

You'll need to do this *before* running `vara-build-pivotal`
