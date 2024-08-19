#import <Cocoa/Cocoa.h>

@interface Controller : NSObject {
}

- (void)start;
- (void)setMode:(BOOL)click;
- (BOOL)getClickMode;
- (void)resetClickMode;

@end

typedef struct {
  float x, y;
} mtPoint;

typedef struct {
	mtPoint f1, f2;
} LoggedClick;

extern LoggedClick recent_clicks[ 4 ];
