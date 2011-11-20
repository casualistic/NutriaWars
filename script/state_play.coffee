
stateclass["state_play"] = class StatePlay extends State
  constructor: (@parent) ->
    console.log "Construct play state"
    
    @spawnEnemyTime = 3*1000
    @spawnEnemyDelay = @spawnEnemyTime 
    @maxEnemies = 10
    
    @camera = new Camera {"projection": "normal", "vpWidth": @parent.width, "vpHeight": @parent.height}
    
    
    @enemies = []
    for i in [0..@maxEnemies]
      @enemies[i] = new Enemy
      @enemies[i].isAlive = false
      @enemies[i].state = "attack"
   
    @bullets = []
    for i in [0..20]
      @bullets[i] = new Bullet
      
    @hero = new Hero @parent.eventmanager, @parent.keyboard, @bullets
    @hero.coor = new Vector( @parent.width/2, @parent.height/2 )
   

  spawnEnemy: () ->
   console.log "StatePlay: createEnemy()"
   for enemy in @enemies
    if !enemy.isAlive
      enemy.attack(@hero.coor)
      break

  update: (delta) ->
    @spawnEnemyDelay -= delta
    if(@spawnEnemyDelay <= 0)
      @spawnEnemy()
      @spawnEnemyDelay = @spawnEnemyTime
    
    @hero.update(delta)
    
    # TODO: Better collision detection
    for enemy in @enemies
      enemy.update delta
      # Check distance to Hero
      dist = @hero.coor.subtract(enemy.coor).length()
      if dist < 50 and enemy.isAlive
        console.log "StatePlay: GAME OVER"
        @destroy( "state_game_over")
    
    # Check distance to Bullet
    for bullet in @bullets
      bullet.update delta
      for enemy in @enemies
        dist = bullet.coor.subtract(enemy.coor).length()
        if (dist < 10 and enemy.isAlive)
          console.log "StatePlay: bullet hits enemy"
          bullet.kill()
          enemy.kill()
    
  render: (ctx) ->
    @camera.apply ctx, =>
      @hero.render(ctx)
      for bullet in @bullets
        bullet.render ctx
      for enemy in @enemies
        enemy.render ctx
        
      ctx.fillStyle = '#00ff00';
      ctx.fillText('Use arrows to rotate and space to shoot', 20, 460 )

  destroy: (nextState) ->
    for enemy in @enemies
      enemy.kill()
    for bullet in @bullets
      bullet.kill()
    
    @parent.stateManager.setState nextState
    
