private class MyFluidData implements DwFluid2D.FluidData {

  @Override
    // this is called during the fluid-simulation update step.
    public void update(DwFluid2D fluid) {

    float px, py, vx, vy, radius, vscale;

    boolean mouse_input = mousePressed;
    if (mouse_input ) {

      vscale = 15;
      px     = mouseX;
      py     = height-mouseY;
      vx     = (mouseX - pmouseX) * +vscale;
      vy     = (mouseY - pmouseY) * -vscale;

      if (mouseButton == LEFT) {
        radius = 20;
        fluid.addVelocity(px, py, radius, vx, vy);
      }
      if (mouseButton == CENTER) {
        radius = 50;
        fluid.addDensity (px, py, radius, 1.0f, 0.0f, 0.40f, 1f, 1);
      }
      if (mouseButton == RIGHT) {
        radius = 15;
        fluid.addTemperature(px, py, radius, 15f);
      }
    }

    // use the text as input for density
    float mix = fluid.simulation_step == 0 ? 1.0f : 0.01f;
    addDensityTexture(fluid, pg_image, mix);
  }

  // custom shader, to add density from a texture (PGraphics2D) to the fluid.
  public void addDensityTexture(DwFluid2D fluid, PGraphics2D pg, float mix) {
    int[] pg_tex_handle = new int[1];
    //      pg_tex_handle[0] = pg.getTexture().glName;
    context.begin();
    context.getGLTextureHandle(pg, pg_tex_handle);
    context.beginDraw(fluid.tex_density.dst);
    DwGLSLProgram shader = context.createShader(this, "data/addDensity.frag");
    shader.begin();
    shader.uniform2f     ("wh", fluid.fluid_w, fluid.fluid_h);                                                                   
    shader.uniform1i     ("blend_mode", 6);   
    shader.uniform1f     ("mix_value", mix);     
    shader.uniform1f     ("multiplier", 1);     
    shader.uniformTexture("tex_ext", pg_tex_handle[0]);
    shader.uniformTexture("tex_src", fluid.tex_density.src);
    shader.drawFullScreenQuad();
    shader.end();
    context.endDraw();
    context.end("app.addDensityTexture");
    fluid.tex_density.swap();
  }
}
