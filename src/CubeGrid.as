package {
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.ColorTransform;
	import flash.media.Camera;
	import flash.media.Video;
	import zsort.SimpleZSorter;
	
	/**
	 * The primany class in the demo, containing the grid of 'cell' Sprites
	 * 
	 * @author Adam Vernon
	 */
	public class CubeGrid extends Sprite {
		
		private var _cellArray:Array = new Array();
		
		private const _cellW:Number = 15;
		private const _cellH:Number = 15;
		private const _zRange:Number = 200;
		
		private var _scaleFac:Number;
		private var _outW:Number;
		private var _outH:Number;
		
		private var _xCount:Number;
		private var _yCount:Number;
		
		private var _pixelColour:uint;
		private var _pixelString:String;
		private const _colourMultiplier:Number = 0.6;
		
		private var _clipI:int; 		//overall cell iterator
		private var _xI:int; 			//x-axis grid iterator 
		private var _yI:int; 			//y-axis grid iterator 
		
		private var colTrans:ColorTransform = new ColorTransform();
		
		
		/**
		 * Create a new CubeGrid object
		 * 
		 * @param	scaleFactor
		 * 			The multiplier relating the base width and height dimensions
		 * 			to the eventual grid size
		 * 
		 * @param	baseW
		 * 			Base width of the grid, used mainly for aspect ratio
		 * 
		 * @param	baseH
		 * 			Base height of the grid, used mainly for aspect ratio
		 */
		public function CubeGrid(scaleFactor:Number, baseW:Number, baseH:Number) {
			_scaleFac = scaleFactor;
			
			// Set grid dimensions in pixels
			_outW = baseW * scaleFactor;
			_outH = baseH * scaleFactor;
			
			// Set grid dimensions in cells 
			_xCount = Math.round(_outW / _cellW);
			_yCount = Math.round(_outH / _cellH);
			
			grid_build();
			
			colTrans.color = 0x00FF00;
		}
		
		/**
		 * Create all the cells of the grid, iterating over the rows and columns,
		 * setting their x and y positions, and add each into the _cellArray
		 */
		private function grid_build():void {
			_clipI = 0;
			for (_xI = 0; _xI < _xCount; _xI ++) {
				for (_yI = 0; _yI < _yCount; _yI ++) {
					_cellArray[_clipI] = cell_make();
					addChild(_cellArray[_clipI]);
					_cellArray[_clipI].x = _xI * _cellW;
					_cellArray[_clipI].y = _yI * _cellH;
					_clipI ++;
				}
			}
		}
		
		/**
		 * Create and return a single 'cell', comprising several 'panel' shapes
		 * corresponding to the front and sides of a cube, with rough shading
		 * on each side to amplify the effect
		 * 
		 * @return The created 'cell' of the grid
		 */
		private function cell_make():Sprite {
			var cell:Sprite = new Sprite();
			var front:Shape = panel_make(0x222222);
			var top:Shape = panel_make(0xDDDDDD);
			var bottom:Shape = panel_make(0x000000);
			var left:Shape = panel_make(0xAAAAAA);
			var right:Shape = panel_make(0x888888);
			
			top.rotationX -= 90;
			top.z += _cellH;
			
			bottom.rotationX += 90;
			bottom.y += _cellH;
			
			left.rotationY -= 90;
			
			right.rotationY -= 90;
			right.x += _cellW;
			
			cell.addChild(bottom);
			cell.addChild(left);
			cell.addChild(right);
			cell.addChild(top);
			cell.addChild(front);
			
			return cell;
		}
		
		/**
		 * Create and return a single 'panel' Shape object, corresponding to a
		 * side of the 'cell'
		 * 
		 * @param	colour
		 * 			The hex colour code for the panel (one of the shades of grey)
		 * 
		 * @return	The created 'panel' of the cell
		 */
		private function panel_make(colour:uint):Shape {
			var panel:Shape = new Shape();
			panel.graphics.beginFill(colour);
			panel.graphics.drawRect(0, 0, _cellW, _cellH);
			panel.graphics.endFill();
			return panel;
		}
		
		/**
		 * Iterate over each cell row and column, then retrieve the corresponding
		 * pixel colour from the supplied bitmap data proportionally closest to
		 * that particular cell position. Next, set the colorTransform property
		 * of the cell to that pixel's colour (with a reduced multiplier to avoid
		 * blowing out the shading), and set the cell's z position to a point
		 * proportional to its averaged brightness.
		 * 
		 * @param	bmd
		 * 			The bitmapdata frame retrieved from the webcam (or some other
		 * 			source)
		 */
		public function cells_update(bmd:BitmapData):void {
			_clipI = 0;
			for (_xI = 0; _xI < _xCount; _xI ++) {
				for (_yI = 0; _yI < _yCount; _yI ++) {
					_pixelColour = bmd.getPixel(Math.round(_xI * _cellW / _scaleFac), Math.round(_yI * _cellH / _scaleFac));
					colTrans.color = _pixelColour;
					colTrans.redMultiplier = _colourMultiplier;
					colTrans.greenMultiplier = _colourMultiplier;
					colTrans.blueMultiplier = _colourMultiplier;
					_cellArray[_clipI].transform.colorTransform = colTrans;
					_cellArray[_clipI].z = _zRange - (_zRange * fractionalBrightness_calculate(_pixelColour)); //For movin' around by brightness
					_clipI++;
				}
			}
			SimpleZSorter.sortClips(this, true);
		}
		
		/**
		 * Split the hex uint into rgb component values (each out of 256), add
		 * them together and divide them by the total possible, to give an
		 * average brightness
		 * 
		 * @param	pixelColour
		 * 			The colour of the pixel taken from the BitmapData instance
		 * 			supplied to cells_update()
		 * 
		 * @return	The fraction of brightness ranging from 0(black) to 1(white)
		 */
		private function fractionalBrightness_calculate(pixelColour:uint):Number {
			return ((pixelColour >> 16 & 0xFF) + (pixelColour >> 8 & 0xFF) + (pixelColour & 0xFF)) / 768; //R+G+B / 3 / 256
		}
	}
}