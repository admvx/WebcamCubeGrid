package {
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.media.Camera;
	import flash.media.Video;
	
	/**
	 * The document class for the demo, initialising the webcam and passing its
	 * data to the main CubeGrid instance
	 * 
	 * @author Adam Vernon
	 */
	public class Main extends Sprite {
		
		private var _grid:CubeGrid;
		
		private var _cam:Camera;
		private var _vid:Video = new Video();
		private var _bmd:BitmapData;
		
		private const _scaleFac:Number = 1.5;
		private const _wagMag:Number = 1;
		private const _maxWagH:Number = 30;
		private const _maxWagV:Number = 30;
		private var _pctMov:Number = 0;
		private var _halfWidth:Number;
		private var _halfHeight:Number;
		
		/**
		 * Set up the application
		 */
		public function Main() {
			// Set target framerate (could likely be lower than this at runtime)
			this.stage.frameRate = 18;
			
			// Set-up camera, video and BitmapData frame
			_cam = Camera.getCamera();
			_cam.setMode(120, 160, stage.frameRate);
			_vid.attachCamera(_cam);
			
			_bmd = new BitmapData(_vid.width, _vid.height, false);
			_bmd.draw(_vid);
			
			_grid = new CubeGrid(_scaleFac, _bmd.width, _bmd.height);
			
			// Add grids to this display object
			addChild(_grid);
			
			// Set initial positions of grid
			_grid.x = (stage.stageWidth - _grid.width) / 2// - 40;
			_grid.y = (stage.stageHeight - _grid.height) / 2// + 50;
			_grid.z = 7;
			
			//Handle new frames
			stage.addEventListener(Event.ENTER_FRAME, stage_enterFrame);
			
			//Handle mouse movement
			stage.addEventListener(MouseEvent.MOUSE_MOVE, rotation_update);
			
			//Prep percentage movement figures
			_halfWidth = stage.stageWidth / 2;
			_halfHeight = stage.stageHeight / 2;
		}
		
		/**
		 * Draw a new frame from the webcam feed into the BitmapData object and
		 * tell the CubeGrid to update upon each new ENTER_FRAME event
		 * 
		 * @param	evt
		 */
		private function stage_enterFrame(evt:Event):void {
			_bmd.draw(_vid);
			_grid.cells_update(_bmd);
		}
		
		/**
		 * Change the 3D rotation of the whole grid upon each MOUSE_MOVE event
		 * 
		 * @param	evt
		 */
		private function rotation_update(evt:MouseEvent):void {
			_pctMov = (evt.stageX - _halfWidth) / _halfWidth;
			rotationY = _maxWagH * _wagMag * _pctMov * -1;
			
			_pctMov = (evt.stageY - _halfHeight) / _halfHeight;
			rotationX = _maxWagV * _wagMag * _pctMov;
		}
		
	}
}