// YTSettingsButton - Tweak.x
// Aggiunge un'icona impostazioni nella homepage di YouTube iOS
// Compatibile con YouTube 19.x+ | Theos + Logos

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// ─── Chiavi per objc_setAssociatedObject ────────────────────────────────────

static const void *kYTSBViewControllerKey = &kYTSBViewControllerKey;
static const void *kYTSBButtonKey         = &kYTSBButtonKey;

// ─── Forward declarations delle classi private di YouTube ───────────────────

@interface YTSettingsViewController : UIViewController
@end

@interface YTRootTabBarViewController : UITabBarController
@end

@interface YTHomeViewController : UIViewController
// Dichiara il metodo aggiunto da %new così il compilatore lo conosce
- (void)ytsb_addSettingsButton;
@end

// ─── Bottone impostazioni ────────────────────────────────────────────────────

@interface YTSBSettingsButton : UIButton
@end

@implementation YTSBSettingsButton

+ (instancetype)buttonForViewController:(UIViewController *)vc {
    YTSBSettingsButton *btn = [YTSBSettingsButton buttonWithType:UIButtonTypeSystem];

    // SF Symbol "gearshape.fill" (iOS 14+), fallback emoji
    UIImage *icon = nil;
    if (@available(iOS 14.0, *)) {
        UIImageSymbolConfiguration *config =
            [UIImageSymbolConfiguration configurationWithPointSize:22
                                                            weight:UIImageSymbolWeightMedium];
        icon = [UIImage systemImageNamed:@"gearshape.fill" withConfiguration:config];
    }

    if (icon) {
        [btn setImage:icon forState:UIControlStateNormal];
        btn.tintColor = UIColor.whiteColor;
    } else {
        [btn setTitle:@"⚙️" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:22];
    }

    btn.frame = CGRectMake(0, 0, 36, 36);
    btn.accessibilityLabel = @"Impostazioni";

    btn.layer.shadowColor   = UIColor.blackColor.CGColor;
    btn.layer.shadowOpacity = 0.35f;
    btn.layer.shadowOffset  = CGSizeMake(0, 1);
    btn.layer.shadowRadius  = 3;

    // Salva riferimento al ViewController con chiave statica (weak, non retain)
    objc_setAssociatedObject(btn, kYTSBViewControllerKey, vc, OBJC_ASSOCIATION_ASSIGN);

    [btn addTarget:btn
            action:@selector(ytsbDidTap)
  forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

- (void)ytsbDidTap {
    UIViewController *vc = objc_getAssociatedObject(self, kYTSBViewControllerKey);
    if (!vc) return;

    // Prova a trovare la classe impostazioni di YouTube (nome varia per versione)
    Class settingsClass = NSClassFromString(@"YTSettingsViewController")
                       ?: NSClassFromString(@"YTUserSettingsViewController")
                       ?: NSClassFromString(@"GOOSettingsViewController");

    if (settingsClass) {
        UIViewController *settingsVC = [[settingsClass alloc] init];
        settingsVC.modalPresentationStyle = UIModalPresentationFormSheet;
        UINavigationController *nav =
            [[UINavigationController alloc] initWithRootViewController:settingsVC];
        [vc presentViewController:nav animated:YES completion:nil];
    } else {
        // Fallback: apri impostazioni iOS
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
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
    [self ytsb_addSettingsButton];
}

%new
- (void)ytsb_addSettingsButton {
    // Evita duplicati: se il bottone è già stato aggiunto non fare nulla
    if (objc_getAssociatedObject(self, kYTSBButtonKey)) return;

    YTSBSettingsButton *btn = [YTSBSettingsButton buttonForViewController:self];
    objc_setAssociatedObject(self, kYTSBButtonKey, btn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];

    NSMutableArray *rightItems =
        [self.navigationItem.rightBarButtonItems mutableCopy] ?: [NSMutableArray new];
    [rightItems addObject:item];
    self.navigationItem.rightBarButtonItems = rightItems;
}

%end

// ─── Costruttore ─────────────────────────────────────────────────────────────

%ctor {
    NSLog(@"[YTSettingsButton] Tweak caricato correttamente ✓");
}
