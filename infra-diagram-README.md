This folder contains a Mermaid diagram of the Terraform-managed Azure infrastructure.

Files:
- infra-diagram.mmd — Mermaid diagram source.

Render instructions (requires Node.js):

1. Install the Mermaid CLI (once):

```bash
npm install -g @mermaid-js/mermaid-cli
```

2. Render to SVG:

```bash
mmdc -i infra-diagram.mmd -o infra-diagram.svg
```

3. Render to PNG:

```bash
mmdc -i infra-diagram.mmd -o infra-diagram.png
```

Notes:
- The diagram uses textual labels for Azure services. For production-quality artwork with official Azure icons, use the Azure Architecture Icons set and a diagram editor like draw.io or Visio, then replace the Mermaid shapes with icon images.
