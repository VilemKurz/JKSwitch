//
//  JKSwitch.h  
//  JKSwitch
//
//  (ARC)
//
//  Created by James Kelly on 8/30/12.
//  Copyright (c) 2012 James Kelly All rights reserved.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>

@interface JKSwitch : UIControl

/* views are resized to fill the space between button and background view edges */
@property (strong, nonatomic) UIView *leftView;
@property (strong, nonatomic) UIView *rightView;

/* set these if you wish to displace the views */
@property (nonatomic) UIEdgeInsets rightViewInsets;
@property (nonatomic) UIEdgeInsets leftViewInsets;

@property(nonatomic, getter=isOn) BOOL on;

/* background image width must be (border.width - button.width/2 - padding) * 2 */
/* background, button, border must be of equal height */

- (id)initWithOrigin:(CGPoint)origin
     backgroundImage:(UIImage *)bgImage
         buttonImage:(UIImage *)buttonImage
         borderImage:(UIImage *)borderImage;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
