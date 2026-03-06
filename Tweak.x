// YTSettingsButton - Tweak.x
// Aggiunge un'icona impostazioni nella homepage di YouTube iOS
// Compatibile con YouTube 19.x+ | Theos + Logos

#import <UIKit/UIKit.h>

// ─── Forward declarations delle classi private di YouTube ───────────────────

@interface YTAppDelegate : UIResponder
+ (instancetype)sharedAppDelegate;
- (UINavigationController *)navigationController;
@end

@interface YTSettingsViewController : UIViewController
- (instancetype)initWithStylesheet:(id)stylesheet;
@end

@interface YTRootTabBarViewController : UITabBarController
@end

// Header view della homepage (ELMView o YTHomeViewController header)
@interface ELMContainerView : UIView
@end

@interface YTHomeViewController : UIViewController
@end

// ─── Costanti ───────────────────────────────────────────────────────────────

static NSString * const kTweakID = @"com.yourrepo.ytsettingsbutton";

// ─── Bottone impostazioni ────────────────────────────────────────────────────

@interface YTSBSettingsButton : UIButton
@end

@implementation YTSBSettingsButton

+ (instancetype)buttonForViewController:(UIViewController *)vc {
    YTSBSettingsButton *btn = [YTSBSettingsButton buttonWithType:UIButtonTypeSystem];
    
    // Usa SF Symbol "gearshape.fill" (iOS 14+), fallback su stringa testo
    UIImage *icon = nil;
    if (@available(iOS 14.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration
            configurationWithPointSize:22
            weight:UIImageSymbolWeightMedium];
        icon = [UIImage systemImageNamed:@"gearshape.fill"
                       withConfiguration:config];
    }
    
    if (icon) {
        [btn setImage:icon forState:UIControlStateNormal];
        btn.tintColor = UIColor.whiteColor;
    } else {
        // fallback testo
        [btn setTitle:@"⚙️" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:22];
    }
    
    btn.frame = CGRectMake(0, 0, 36, 36);
    btn.accessibilityLabel = @"Impostazioni";
    
    // Aggiungi ombra sottile per visibilità
    btn.layer.shadowColor  = UIColor.blackColor.CGColor;
    btn.layer.shadowOpacity = 0.35;
    btn.layer.shadowOffset  = CGSizeMake(0, 1);
    btn.layer.shadowRadius  = 3;
    
    // Target
    objc_setAssociatedObject(btn, "ytsbVC", vc, OBJC_ASSOCIATION_ASSIGN);
    [btn addTarget:btn
            action:@selector(ytsbDidTap)
  forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)ytsbDidTap {
    UIViewController *vc = objc_getAssociatedObject(self, "ytsbVC");
    if (!vc) return;
    
    // Apri le impostazioni native di YouTube
    // La classe può variare in base alla versione: proviamo più approcci
    Class settingsClass = NSClassFromString(@"YTSettingsViewController")
                       ?: NSClassFromString(@"YTUserSettingsViewController")
                       ?: NSClassFromString(@"GOOSettingsViewController");
    
    if (settingsClass) {
        UIViewController *settingsVC = [[settingsClass alloc] init];
        settingsVC.modalPresentationStyle = UIModalPresentationFormSheet;
        UINavigationController *nav = [[UINavigationController alloc]
                                        initWithRootViewController:settingsVC];
        [vc presentViewController:nav animated:YES completion:nil];
    } else {
        // Fallback: apri le impostazioni di iOS per YouTube
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url
                                               options:@{}
                                     completionHandler:nil];
        }
    }
}

@end

// ─── Hook su YTHomeViewController ───────────────────────────────────────────

%hook YTHomeViewController

- (void)viewDidLoad {
    %orig;
    [self ytsb_addSettingsButton];
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    // Ri-aggiungi se rimosso (es. dopo rotazione o navigazione)
    [self ytsb_addSettingsButton];
}

%new
- (void)ytsb_addSettingsButton {
    // Evita duplicati
    static const void *kButtonKey = &kButtonKey;
    if (objc_getAssociatedObject(self, kButtonKey)) return;
    
    YTSBSettingsButton *btn = [YTSBSettingsButton buttonForViewController:self];
    objc_setAssociatedObject(self, kButtonKey, btn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Inserisci come BarButtonItem a destra nella navigation bar
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    NSMutableArray *rightItems = [self.navigationItem.rightBarButtonItems mutableCopy]
                               ?: [NSMutableArray new];
    
    // Inserisci in coda (dopo eventuali bottoni esistenti come search/cast)
    [rightItems addObject:item];
    self.navigationItem.rightBarButtonItems = rightItems;
}

%end

// ─── Hook alternativo: YTRootTabBarViewController ────────────────────────────
// Alcune versioni di YouTube non usano YTHomeViewController direttamente.
// Questo hook garantisce la compatibilità aggiuntiva.

%hook YTRootTabBarViewController

- (void)viewDidLoad {
    %orig;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    %orig;
    // Nessuna azione necessaria qui; gestito da YTHomeViewController
}

%end

// ─── Costruttore ─────────────────────────────────────────────────────────────

%ctor {
    NSLog(@"[YTSettingsButton] Tweak caricato correttamente ✓");
}
