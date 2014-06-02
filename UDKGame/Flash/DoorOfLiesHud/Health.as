package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Health extends MovieClip {
		
		private var _currentHealth:Number;
		private var _inicialHeight:Number;
		
		public function Health() {
			_inicialHeight = _mask.height;
			currentHealth = 50;
		}
		
		public function set currentHealth(health:Number)
		{
			_currentHealth = health;
			_mask.height = _inicialHeight * _currentHealth / 100;
		}
		
		public function set SetDamage(damage:Number)
		{
			_currentHealth -= damage;
			_mask.height = _inicialHeight * _currentHealth / 100;
		}
	}
	
}
