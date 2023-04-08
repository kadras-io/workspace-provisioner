# Verifying the Package Release

This package is published as an OCI artifact, signed with Sigstore [Cosign](https://docs.sigstore.dev/cosign/overview), and associated with a [SLSA Provenance](https://slsa.dev/provenance) attestation.

Using `cosign`, you can display the supply chain security related artifacts for the `ghcr.io/kadras-io/workspace-provisioner` images. Use the specific digest you'd like to verify.

```shell
cosign tree ghcr.io/kadras-io/workspace-provisioner
```

The result:

```shell
📦 Supply Chain Security Related artifacts for an image: ghcr.io/kadras-io/workspace-provisioner
└── 💾 Attestations for an image tag: ghcr.io/kadras-io/workspace-provisioner:sha256-18b6ce3b289f61a86bde3e42be9919019483f3dceef08ba43cafc83b9fd15b62.att
   └── 🍒 sha256:02f4445d35f75d4f1c473934686ffb1c5c3126f4af5909f95ba9c3b6b04abe03
└── 🔐 Signatures for an image tag: ghcr.io/kadras-io/workspace-provisioner:sha256-18b6ce3b289f61a86bde3e42be9919019483f3dceef08ba43cafc83b9fd15b62.sig
   └── 🍒 sha256:566d0ecb9e67ee23f91fd1e5bb0d36f7714dee0dcd2eba83153a4abcac29b5c7
```

You can verify the signature and its claims:

```shell
cosign verify \
   --certificate-identity-regexp https://github.com/kadras-io \
   --certificate-oidc-issuer https://token.actions.githubusercontent.com \
   ghcr.io/kadras-io/workspace-provisioner | jq
```

You can also verify the SLSA Provenance attestation associated with the image.

```shell
cosign verify-attestation --type slsaprovenance \
   --certificate-identity-regexp https://github.com/slsa-framework \
   --certificate-oidc-issuer https://token.actions.githubusercontent.com \
   ghcr.io/kadras-io/workspace-provisioner | jq .payload -r | base64 --decode | jq
```
