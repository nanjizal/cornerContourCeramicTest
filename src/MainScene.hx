package;

import ceramic.Text;
import ceramic.Quad;
import ceramic.Scene;
import ceramic.Mesh;
import ceramic.Color;
import ceramic.AlphaColor;

// contour code
import cornerContour.Sketcher;
import cornerContour.Pen2D;
import cornerContour.StyleSketch;
import cornerContour.StyleEndLine;
import cornerContour.shape.ShapeXML;

// SVG path parser
import justPath.*;
import justPath.transform.ScaleContext;
import justPath.transform.ScaleTranslateContext;
import justPath.transform.TranslationContext;

class MainScene extends Scene {

    var rect1: ShapeXML = '<rect x="10" y="10" width="30" height="30" fill="0xffFF0000"/>';
    var rect3: ShapeXML = '<rect x="100" y="10" width="30" height="30" stroke="0xffffc000" stroke_width="5"/>';
    var rect2: ShapeXML = '<rect x="60" y="10" rx="10" ry="10" width="50" height="30" stroke="0xff000000" fill="0xffff0000" stroke_width="5"/>';
    
    
    var circle1: ShapeXML = '<circle cx="25" cy="75" r="20" stroke="0xffFF0000" fill="0xff00ff00" stroke_width="5"/>';
    var ellipse1: ShapeXML = '<ellipse cx="75" cy="75" rx="20" ry="5" stroke="0xffFF0000" fill="0xff0000ff" stroke_width="5"/>';
    
    
    var line1: ShapeXML = '<line x1="50." y1="70." x2="55." y2="76." stroke="0xffFF7F00" stroke_width="5"/>';
    
    
    var polyline1: ShapeXML = '<polyline points="60,110 65,120 70,115 75,130 80,125 85,140 90,135 95,150 100,145" stroke="0xffFF7F00" stroke_width="3"/>';
    var polygon1: ShapeXML = '<polygon points="50,160 55,180 70,180 60,190 65,205 50,195 35,205 40,190 30,180 45,180" stroke="0xffFF0f0f" fill="0xff00ff00" stroke_width="1"/>';

    var logo:Quad;
    var mesh: Mesh;
    var text:Text;
    
    var sketcher:       Sketcher;
    var pen2D:          Pen2D;
    
    var quadtest_d      = "M200,300 Q400,50 600,300 T1000,300";
    var cubictest_d     = "M100,200 C100,100 250,100 250,200S400,300 400,200";
    
    override function preload() {

        // Add any asset you want to load here

    }
    
    override function create() {

        // Called when scene has finished preloading
        
        mesh = new Mesh();
        drawMesh();
        
        mesh.anchor(0, 0);
        mesh.pos(0, 0);
        mesh.scale( 1 );
        mesh.alpha = 1;
        mesh.colorMapping = VERTICES;
        
        add(mesh);
        
        // Print some log
        log.success('Hello from ceramic :)');

    }

    override function update(delta:Float) {
        
        // Here, you can add code that will be executed at every frame

    }

    override function resize(width:Float, height:Float) {

        // Called everytime the scene size has changed

    }

    override function destroy() {

        // Perform any cleanup before final destroy

        super.destroy();

    }
    
    /** 
     * draws the svgs
     */
    public
    function drawMesh(){
        pen2D = new Pen2D( 0xFF0000FF );
        
        rect1.draw( pen2D );
        rect3.draw( pen2D );
        rect2.draw( pen2D, 50., 0., 5., 5. );
        circle1.draw( pen2D, 20., 50., 2., 2. );
        ellipse1.draw( pen2D,0,0,3,3 );
        line1.draw( pen2D, 0.,0.,10.,30. );
        line1.draw( pen2D, 0.,0.,20.,10. );
        polyline1.draw( pen2D, 0.,0.,3.,3. );
        polygon1.draw( pen2D, 0., 0., 2, 2 );
        trace( 'pen2D');
        // render svg
        arcSVG();
        pen2D.currentColor = 0xff0000FF;
        birdSVG();
        cubicSVG();
        quadSVG();
        /*
        mesh.colors = [ 0xFFFF0000, 0xFFFF0000, 0xFFFF0000 ];
        mesh.vertices = [ 150, 150, 470, 400, 650, 200 ]; // A list of x,y coordinates
        mesh.indices = [ 0,1,2 ]; // A list of indices to form triangles
        */
        rearrageDrawData();
    }
    public
    function rearrageDrawData(){
        var pen = pen2D;
        var data = pen.arr;
        var totalTriangles = Std.int( data.size/7 );
        var count = 0;
        for( i in 0...totalTriangles ){
            pen.pos = i;
            var l = mesh.vertices.length;
            mesh.vertices[ l ]     = data.ax;
            mesh.vertices[ l + 1 ] = data.ay;
            mesh.vertices[ l + 2 ] = data.bx;
            mesh.vertices[ l + 3 ] = data.by;
            mesh.vertices[ l + 4 ] = data.cx;
            mesh.vertices[ l + 5 ] = data.cy;
            l = mesh.colors.length;
            mesh.colors[ l ]     = cast data.color;
            mesh.colors[ l + 1 ] = cast data.color;
            mesh.colors[ l + 2 ] = cast data.color;
            l = mesh.indices.length;
            mesh.indices[ l ] = count;
            count++;
            mesh.indices[ l + 1 ] = count;
            count++;
            mesh.indices[ l + 2 ] = count;
            count++;
        }
    }
    /**
     * draws Kiwi svg
     */
    public
    function birdSVG(){
        var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.both );
        sketcher.width = 2;
        var scaleTranslateContext = new ScaleTranslateContext( sketcher, 20, 0, 1, 1 );
        var p = new SvgPath( scaleTranslateContext );
        p.parse( bird_d );
    }
    /** 
     * draws cubic SVG
     */
    public
    function cubicSVG(){
        var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.both );
        sketcher.width = 10;
        // function to adjust color of curve along length
        sketcher.colourFunction = function( colour: Int, x: Float, y: Float, x_: Float, y_: Float ):  Int {
            return Math.round( colour-1*x*y );
        }
        var translateContext = new TranslationContext( sketcher, 50, 200 );
        var p = new SvgPath( translateContext );
        p.parse( cubictest_d );
    }
    /**
     * draws quad SVG
     */
    public
    function quadSVG(){
        var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.both );
        sketcher.width = 1;
        // function to adjust width of curve along length
        sketcher.widthFunction = function( width: Float, x: Float, y: Float, x_: Float, y_: Float ): Float{
            return width+0.008*2;
        }
        var translateContext = new ScaleTranslateContext( sketcher, 0, 100, 0.5, 0.5 );
        var p = new SvgPath( translateContext );
        p.parse( quadtest_d );
    }
    /**
     * draws elipse arcs
     */
    public
    function arcSVG(){
        var arcs0  = [ arc0_0, arc0_1, arc0_2, arc0_3 ];
        var arcs1  = [ arc1_0, arc1_1, arc1_2, arc1_3 ];
        var arcs2  = [ arc2_0, arc2_1, arc2_2, arc2_3 ];
        var arcs3  = [ arc3_0, arc3_1, arc3_2, arc3_3 ];
        var arcs4  = [ arc4_0, arc4_1, arc4_2, arc4_3 ];
        var arcs5  = [ arc5_0, arc5_1, arc5_2, arc5_3 ];
        var arcs6  = [ arc6_0, arc6_1, arc6_2, arc6_3 ];
        var arcs7  = [ arc7_0, arc7_1, arc7_2, arc7_3 ];
        var pallet = [ silver, gainsboro, lightGray, crimson ];
        var x0 = 130;
        var x1 = 450;
        var yPos = [ -30, 100, 250, 400 ];
        var arcs = [ arcs0, arcs1, arcs2, arcs3, arcs4, arcs5, arcs6, arcs7 ];
        for( i in 0...yPos.length ){
            drawSet( arcs.shift(), pallet, x0, yPos[i], 0.5 );
            drawSet( arcs.shift(), pallet, x1, yPos[i], 0.5 );
        }
    }
    // draws a set of svg ellipses.
    function drawSet( arcs: Array<String>, col:Array<Int>, x: Float, y: Float, s: Float ){    
        for( i in 0...arcs.length ) draw_d( arcs[ i ], x, y, s, 1., col[ i ] );
    }
    // draws an svg ellipse
    function draw_d( d: String, x: Float, y: Float, s: Float, w: Float, color: Int ){
        pen2D.currentColor = color;
        var sketcher = new Sketcher( pen2D, StyleSketch.Fine, StyleEndLine.both );
        sketcher.width = w;
        var trans = new ScaleTranslateContext( sketcher, x, y, s, s );
        var p = new SvgPath( trans );
        p.parse( d );
    }
    
    // elipses
    var crimson     = 0xFFDC143C;
    var silver      = 0xFFC0C0C0;
    var gainsboro   = 0xFFDCDCDC;
    var lightGray   = 0xFFD3D3D3;
    var arc0_0      = "M 100 200 A 100 50 0.0 0 1 250 150";
    var arc0_1      = "M 100 200 A 100 50 0.0 1 0 250 150";
    var arc0_2      = "M 100 200 A 100 50 0.0 1 1 250 150";
    var arc0_3      = "M 100 200 A 100 50 0.0 0 0 250 150";
    var arc1_0      = "M 100 200 A 100 50 0.0 0 0 250 150";
    var arc1_1      = "M 100 200 A 100 50 0.0 1 0 250 150";
    var arc1_2      = "M 100 200 A 100 50 0.0 1 1 250 150";
    var arc1_3      = "M 100 200 A 100 50 0.0 0 1 250 150";
    var arc2_0      = "M 100 200 A 100 50 -15 0 0 250 150";
    var arc2_1      = "M 100 200 A 100 50 -15 0 1 250 150";
    var arc2_2      = "M 100 200 A 100 50 -15 1 1 250 150";
    var arc2_3      = "M 100 200 A 100 50 -15 1 0 250 150";
    var arc3_0      = "M 100 200 A 100 50 -15 0 0 250 150";
    var arc3_1      = "M 100 200 A 100 50 -15 0 1 250 150";
    var arc3_2      = "M 100 200 A 100 50 -15 1 0 250 150";
    var arc3_3      = "M 100 200 A 100 50 -15 1 1 250 150";
    var arc4_0      = "M 100 200 A 100 50 -44 1 0 250 150";
    var arc4_1      = "M 100 200 A 100 50 -44 0 1 250 150";
    var arc4_2      = "M 100 200 A 100 50 -44 1 1 250 150";
    var arc4_3      = "M 100 200 A 100 50 -44 0 0 250 150";
    var arc5_0      = "M 100 200 A 100 50 -44 0 0 250 150";
    var arc5_1      = "M 100 200 A 100 50 -44 1 1 250 150";
    var arc5_2      = "M 100 200 A 100 50 -44 1 0 250 150";
    var arc5_3      = "M 100 200 A 100 50 -44 0 1 250 150";
    var arc6_0      = "M 100 200 A 100 50 -45 0 0 250 150";
    var arc6_1      = "M 100 200 A 100 50 -45 0 1 250 150";
    var arc6_2      = "M 100 200 A 100 50 -45 1 1 250 150";
    var arc6_3      = "M 100 200 A 100 50 -45 1 0 250 150";
    var arc7_0      = "M 100 200 A 100 50 -45 0 0 250 150";
    var arc7_1      = "M 100 200 A 100 50 -45 0 1 250 150";
    var arc7_2      = "M 100 200 A 100 50 -45 1 0 250 150";
    var arc7_3      = "M 100 200 A 100 50 -45 1 1 250 150";
    

    // kiwi bird
    var bird_d = "M210.333,65.331C104.367,66.105-12.349,150.637,1.056,276.449c4.303,40.393,18.533,63.704,52.171,79.03c36.307,16.544,57.022,54.556,50.406,112.954c-9.935,4.88-17.405,11.031-19.132,20.015c7.531-0.17,14.943-0.312,22.59,4.341c20.333,12.375,31.296,27.363,42.979,51.72c1.714,3.572,8.192,2.849,8.312-3.078c0.17-8.467-1.856-17.454-5.226-26.933c-2.955-8.313,3.059-7.985,6.917-6.106c6.399,3.115,16.334,9.43,30.39,13.098c5.392,1.407,5.995-3.877,5.224-6.991c-1.864-7.522-11.009-10.862-24.519-19.229c-4.82-2.984-0.927-9.736,5.168-8.351l20.234,2.415c3.359,0.763,4.555-6.114,0.882-7.875c-14.198-6.804-28.897-10.098-53.864-7.799c-11.617-29.265-29.811-61.617-15.674-81.681c12.639-17.938,31.216-20.74,39.147,43.489c-5.002,3.107-11.215,5.031-11.332,13.024c7.201-2.845,11.207-1.399,14.791,0c17.912,6.998,35.462,21.826,52.982,37.309c3.739,3.303,8.413-1.718,6.991-6.034c-2.138-6.494-8.053-10.659-14.791-20.016c-3.239-4.495,5.03-7.045,10.886-6.876c13.849,0.396,22.886,8.268,35.177,11.218c4.483,1.076,9.741-1.964,6.917-6.917c-3.472-6.085-13.015-9.124-19.18-13.413c-4.357-3.029-3.025-7.132,2.697-6.602c3.905,0.361,8.478,2.271,13.908,1.767c9.946-0.925,7.717-7.169-0.883-9.566c-19.036-5.304-39.891-6.311-61.665-5.225c-43.837-8.358-31.554-84.887,0-90.363c29.571-5.132,62.966-13.339,99.928-32.156c32.668-5.429,64.835-12.446,92.939-33.85c48.106-14.469,111.903,16.113,204.241,149.695c3.926,5.681,15.819,9.94,9.524-6.351c-15.893-41.125-68.176-93.328-92.13-132.085c-24.581-39.774-14.34-61.243-39.957-91.247c-21.326-24.978-47.502-25.803-77.339-17.365c-23.461,6.634-39.234-7.117-52.98-31.273C318.42,87.525,265.838,64.927,210.333,65.331zM445.731,203.01c6.12,0,11.112,4.919,11.112,11.038c0,6.119-4.994,11.111-11.112,11.111s-11.038-4.994-11.038-11.111C434.693,207.929,439.613,203.01,445.731,203.01z";

    
    
}
