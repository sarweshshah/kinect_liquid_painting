import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.dwgl.DwGLSLProgram;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import com.thomasdiewald.pixelflow.java.fluid.DwFluidParticleSystem2D;

import processing.core.*;
import processing.opengl.PGraphics2D;

int fluidgrid_scale = 1;

DwPixelFlow context;
DwFluid2D fluid;

MyFluidData cb_fluid_data;
DwFluidParticleSystem2D particle_system;

PGraphics2D pg_fluid;       // render target
PGraphics2D pg_image;       // texture-buffer, for adding fluid data

PImage image;

// some state variables for the GUI/display
int     BACKGROUND_COLOR           = 0;
int     DISPLAY_fluid_texture_mode = 0;


public void settings() {
  //size(viewport_w, viewport_h, P2D);
  fullScreen(P2D);
  smooth(4);
}


public void setup() {
  int viewport_w = width;
  int viewport_h = height;

  // main library context
  context = new DwPixelFlow(this);

  // fluid simulation
  fluid = new DwFluid2D(context, viewport_w, viewport_h, fluidgrid_scale);

  // some fluid parameters
  fluid.param.dissipation_density     = 1.00f;
  fluid.param.dissipation_velocity    = 0.95f;
  fluid.param.dissipation_temperature = 0.70f;
  fluid.param.vorticity               = 0.50f;

  // interface for adding data to the fluid simulation
  cb_fluid_data = new MyFluidData();
  fluid.addCallback_FluiData(cb_fluid_data);

  // image, used for density
  image = loadImage("./data/IMG_1157.JPG");

  // fluid render target
  pg_fluid = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
  pg_fluid.smooth(4);

  // particles
  particle_system = new DwFluidParticleSystem2D();
  particle_system.resize(context, viewport_w/3, viewport_h/3);

  // image/buffer that will be used as density input
  pg_image = (PGraphics2D) createGraphics(viewport_w, viewport_h, P2D);
  pg_image.noSmooth();
  pg_image.beginDraw();
  pg_image.clear();
  pg_image.translate(width/2, height/2);
  pg_image.scale(viewport_h / (float)image.height);
  pg_image.imageMode(CENTER);
  pg_image.image(image, 0, 0);
  pg_image.endDraw();

  background(0);
  frameRate(60);
}


public void draw() {
  fluid.update();
  particle_system.update(fluid);


  pg_fluid.beginDraw();
  pg_fluid.background(BACKGROUND_COLOR);
  pg_fluid.endDraw();

  fluid.renderFluidTextures(pg_fluid, DISPLAY_fluid_texture_mode);

  // display
  image(pg_fluid, 0, 0);
}
