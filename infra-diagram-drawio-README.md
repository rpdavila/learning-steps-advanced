Draw.io diagram with Azure icon instructions

Files:
- infra-diagram.drawio — draw.io file with layout and labeled shapes representing the Terraform-managed Azure infrastructure.

Goal:
- Replace the rectangle/shape placeholders with official Azure icons for a polished diagram.

Steps to add official Azure icons (recommended):

1) Download the Azure Architecture Icons pack (SVG/PNG) from Microsoft:
   - Official: https://learn.microsoft.com/azure/architecture/icons/
   - Or GitHub repo: https://github.com/microsoft/azure-architecture-icons

2) Open `infra-diagram.drawio` in draw.io (diagrams.net).

3) Replace a shape with an icon:
   - Select the shape you want to replace.
   - Use `Arrange -> Insert -> Image...` and pick the downloaded SVG/PNG for the Azure service (e.g., AKS, Container Registry, Key Vault, Database).
   - Resize and align to match existing boxes.

4) Add role/connection labels as needed using the text tool.

5) Export to PNG/SVG/PDF via `File -> Export as -> PNG/SVG/PDF`.

Quick tips:
- If you prefer linking icons from URLs instead of embedding, use `Arrange -> Insert -> Image -> URL` and paste a hosted icon URL.
- For consistent styling, use the same icon size and enable `Constrain proportions` when resizing.

If you want, I can:
- Embed official Azure icons directly into the `.drawio` file (will increase file size), or
- Produce a high-resolution PNG export for you now if you want that image instead.

Which would you like next? (embed icons / export PNG / nothing)