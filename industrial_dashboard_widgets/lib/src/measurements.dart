import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'common.dart';
import 'models.dart';
import 'theme.dart';
import 'equipment_models.dart';

/// Scale configuration for a linear measurement.
@immutable
class LinearGaugeStyle {
  /// Creates a horizontal or vertical scale.
  const LinearGaugeStyle({this.orientation = Axis.horizontal, this.showScale = true});
  /// Physical fill direction: left-right or bottom-up; independent of text direction.
  final Axis orientation;
  /// Display numeric endpoint labels.
  final bool showScale;
}

/// Linear engineering measurement with colored bands and target marker.
class IndustrialLinearGauge extends StatelessWidget {
  /// Creates a controlled gauge. Target must be finite.
  IndustrialLinearGauge({super.key, required this.label, required this.reading,
    required this.range, this.unit = '', this.target, this.formatter,
    this.style = const LinearGaugeStyle(), List<IndustrialBand> bands = const [], this.theme}) : bands = List.unmodifiable(bands) {
    if (target != null && !target!.isFinite) throw ArgumentError('Target must be finite.');
  }
  /// Instrument label.
  final String label;
  /// Actual measurement and status.
  final IndustrialReading reading;
  /// Visual range; actual labels are never clamped.
  final IndustrialRange range;
  /// Engineering units.
  final String unit;
  /// Optional finite setpoint.
  final double? target;
  /// Number formatter.
  final ValueFormatter? formatter;
  /// Orientation and scale visibility.
  final LinearGaugeStyle style;
  /// Colored operating intervals.
  final List<IndustrialBand> bands;
  /// Local design tokens.
  final IndustrialTheme? theme;
  @override
  Widget build(BuildContext context) {
    final t = theme ?? IndustrialTheme.of(context);
    return Semantics(label: readingSemantics(label, reading, unit, formatter, range),
      child: ExcludeSemantics(child: InstrumentPanel(theme: t, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Text(label), const SizedBox(height: 8), Text('${reading.format(formatter)} $unit', style: t.valueStyle.copyWith(color:t.foreground)),
        const SizedBox(height: 12), RepaintBoundary(child: SizedBox(height:style.orientation == Axis.horizontal ? 40 : 150,
          child: CustomPaint(painter:_LinearPainter(range,reading.hasValue ? reading.value : null,target,bands,style.orientation,t)))),
        if(style.showScale) Wrap(alignment:WrapAlignment.spaceBetween,spacing:16,children:[Text('${range.min}'),Text('${range.max}')]),
        if(target!=null) Text('${t.text('Target')}: ${formatter?.call(target!) ?? target} $unit'),
        ReadingStatus(reading:reading,theme:t,range:range),
      ]))));
  }
}
class _LinearPainter extends CustomPainter {
  _LinearPainter(this.range,this.value,this.target,this.bands,this.axis,this.theme);
  final IndustrialRange range; final double? value,target; final List<IndustrialBand> bands; final Axis axis; final IndustrialTheme theme;
  @override
  void paint(Canvas canvas,Size size){
    final vertical=axis==Axis.vertical;
    final r=vertical?Rect.fromLTWH(size.width/2-18,4,36,size.height-8):Rect.fromLTWH(4,8,size.width-8,24);
    final paint=Paint()..color=theme.border;
    canvas.drawRRect(RRect.fromRectAndRadius(r,const Radius.circular(6)),paint);
    Rect section(double a,double b)=>vertical?Rect.fromLTRB(r.left,r.bottom-b*r.height,r.right,r.bottom-a*r.height):Rect.fromLTRB(r.left+a*r.width,r.top,r.left+b*r.width,r.bottom);
    for(final b in bands) {canvas.drawRect(section(range.fraction(b.range.min),range.fraction(b.range.max)),paint..color=b.color.withValues(alpha:.35));}
    if(value!=null)canvas.drawRect(section(0,range.fraction(value!)).deflate(4),paint..color=theme.accent);
    if(target!=null){final f=range.fraction(target!);paint..color=theme.foreground..strokeWidth=3;
      if(vertical){final y=r.bottom-r.height*f;canvas.drawLine(Offset(r.left-5,y),Offset(r.right+5,y),paint);}
      else{final x=r.left+r.width*f;canvas.drawLine(Offset(x,r.top-5),Offset(x,r.bottom+5),paint);}}
  }
  @override
  bool shouldRepaint(_LinearPainter old)=>range!=old.range||value!=old.value||target!=old.target||bands!=old.bands||axis!=old.axis||theme!=old.theme;
}

/// Numeric display rendering style.
enum DigitalPresentation {
  /// Standard accessible typography.
  standard,
  /// Seven-segment numerals without glow; semantics retain the original text.
  sevenSegment,
}

/// Readable numeric display with optional seven-segment rendering.
class IndustrialDigitalDisplay extends StatelessWidget {
  /// Creates a display. Precision must be between zero and six.
  IndustrialDigitalDisplay({super.key,required this.label,required this.reading,this.unit='',this.precision=1,
    this.showPositiveSign=false,this.presentation=DigitalPresentation.standard,this.formatter,this.theme}){
    if(precision<0||precision>6)throw ArgumentError('Precision must be 0–6.');
  }
  /// Instrument name.
  final String label;
  /// Controlled actual reading.
  final IndustrialReading reading;
  /// Engineering unit.
  final String unit;
  /// Decimal places when no formatter is supplied.
  final int precision;
  /// Prefix positive values with a plus sign.
  final bool showPositiveSign;
  /// Numeric visual style.
  final DigitalPresentation presentation;
  /// Overrides precision; nonnumeric output falls back to standard typography.
  final ValueFormatter? formatter;
  /// Local theme.
  final IndustrialTheme? theme;
  @override
  Widget build(BuildContext context){
    final t=theme??IndustrialTheme.of(context);
    final text=reading.format(formatter??(v)=>'${showPositiveSign&&v>0?'+':''}${v.toStringAsFixed(precision)}');
    return Semantics(label:'$label: $text $unit. ${reading.status}',child:ExcludeSemantics(child:InstrumentPanel(theme:t,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,mainAxisSize:MainAxisSize.min,children:[
      Text(label),const SizedBox(height:12),
      if(presentation==DigitalPresentation.sevenSegment && RegExp(r'^[0-9.+−—\-]+$').hasMatch(text))
        SizedBox(height:64,child:CustomPaint(painter:_DigitsPainter(text,t.accent,t.border)))
      else Text(text,style:t.valueStyle.copyWith(color:t.foreground,fontFamily:'monospace')),
      if(unit.isNotEmpty)Text(unit,style:TextStyle(color:t.muted)),ReadingStatus(reading:reading,theme:t),
    ]))));
  }
}
class _DigitsPainter extends CustomPainter{
  _DigitsPainter(this.text,this.color,this.off);final String text;final Color color,off;
  static const codes={'0':'abcdef','1':'bc','2':'abged','3':'abgcd','4':'fgbc','5':'afgcd','6':'afgecd','7':'abc','8':'abcdefg','9':'abfgcd','-':'g','−':'g','—':'g'};
  @override
  void paint(Canvas canvas,Size size){
    final w=math.min(size.width/math.max(1,text.length),36.0),h=math.min(size.height,w*1.8);
    final paint=Paint()..strokeWidth=math.max(1,w*.09)..strokeCap=StrokeCap.square;
    for(var i=0;i<text.length;i++){
      final x=i*w,y=(size.height-h)/2;
      if(text[i]=='.'){canvas.drawCircle(Offset(x+w*.4,y+h*.9),w*.07,paint..color=color);continue;}
      if(text[i]=='+'){canvas.drawLine(Offset(x+w*.5,y+h*.25),Offset(x+w*.5,y+h*.75),paint..color=color);canvas.drawLine(Offset(x+w*.15,y+h*.5),Offset(x+w*.85,y+h*.5),paint);continue;}
      final lines=[(Offset(.2,.08),Offset(.8,.08)),(Offset(.86,.15),Offset(.86,.44)),(Offset(.86,.56),Offset(.86,.85)),(Offset(.2,.92),Offset(.8,.92)),(Offset(.14,.56),Offset(.14,.85)),(Offset(.14,.15),Offset(.14,.44)),(Offset(.2,.5),Offset(.8,.5))];
      for(var j=0;j<7;j++){final on=(codes[text[i]]??'').contains('abcdefg'[j]);paint.color=on?color:off.withValues(alpha:.25);final a=lines[j].$1,b=lines[j].$2;canvas.drawLine(Offset(x+a.dx*w,y+a.dy*h),Offset(x+b.dx*w,y+b.dy*h),paint);}
    }
  }
  @override
  bool shouldRepaint(_DigitsPainter old)=>text!=old.text||color!=old.color||off!=old.off;
}

/// Determines whether an actual KPI meets its target.
enum FavorableDirection {
  /// Actual at or above target is favorable.
  higher,
  /// Actual at or below target is favorable.
  lower,
}

/// Actual versus target with an explicit favorable direction.
class IndustrialKpiCard extends StatelessWidget {
  /// Target must be finite and positive; actual can be negative or missing.
  IndustrialKpiCard({super.key,required this.label,required this.actual,required this.target,
    this.direction=FavorableDirection.higher,this.unit='',this.comparisonPeriod,this.formatter,this.theme}){
    if(!target.isFinite||target<=0)throw ArgumentError('KPI target must be finite and positive.');
  }
  /// KPI name.
  final String label;
  /// Observed value with data state.
  final IndustrialReading actual;
  /// Positive reference target.
  final double target;
  /// Interpretation of success.
  final FavorableDirection direction;
  /// Engineering unit.
  final String unit;
  /// Application-supplied comparison period description.
  final String? comparisonPeriod;
  /// Finite-number formatter.
  final ValueFormatter? formatter;
  /// Local theme.
  final IndustrialTheme? theme;
  /// Whether an available actual meets the direction-aware target; null if missing.
  bool? get isFavorable=>!actual.hasValue?null:direction==FavorableDirection.higher?actual.value!>=target:actual.value!<=target;
  @override
  Widget build(BuildContext context){final t=theme??IndustrialTheme.of(context);return InstrumentPanel(theme:t,child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,mainAxisSize:MainAxisSize.min,children:[
    Text(label),const SizedBox(height:8),Text('${actual.format(formatter)} $unit',style:t.valueStyle.copyWith(color:t.foreground)),
    Text('${t.text('Target')}: ${formatter?.call(target)??target} $unit'),const SizedBox(height:12),
    LinearProgressIndicator(value:actual.hasValue?(actual.value!/target).clamp(0.0,1.0):0,color:isFavorable==true?t.accent:t.warning,backgroundColor:t.border),
    const SizedBox(height:8),Text(t.text(isFavorable==null?'No data':isFavorable!?'On target':'Off target')),
    Text(t.text(direction==FavorableDirection.lower?'Lower is favorable':'Higher is favorable'),style:TextStyle(color:t.muted)),
    if(actual.hasValue&&(actual.value!<0||actual.value!>target))Text(t.text('Progress capped; actual preserved')),
    if(comparisonPeriod!=null)Text(comparisonPeriod!),ReadingStatus(reading:actual,theme:t),
  ]));}
}

/// Compact named state appearance.
enum StateIndicatorPresentation {
  /// Disc with an outlined ring.
  led,
  /// Small filled dot with text.
  dot,
  /// Bordered badge.
  badge,
  /// Icon and text only.
  label,
}

/// Custom named machine state with text, icon and optional deliberate announcement.
class IndustrialStateIndicator extends StatelessWidget {
  /// Creates a controlled state indicator. Announcements default off.
  const IndustrialStateIndicator({super.key,required this.state,this.presentation=StateIndicatorPresentation.badge,this.announceChanges=false,this.theme});
  /// Application-owned named state.
  final IndustrialState state;
  /// Compact appearance.
  final StateIndicatorPresentation presentation;
  /// Opt-in live-region announcement for meaningful state transitions only.
  final bool announceChanges;
  /// Local theme.
  final IndustrialTheme? theme;
  @override
  Widget build(BuildContext context){final t=theme??IndustrialTheme.of(context);return Semantics(liveRegion:announceChanges,label:state.label,child:ExcludeSemantics(child:Container(
    padding:EdgeInsets.all(presentation==StateIndicatorPresentation.badge?8:2),
    decoration:presentation==StateIndicatorPresentation.badge?BoxDecoration(border:Border.all(color:state.color),borderRadius:BorderRadius.circular(t.radius)):null,
    child:Wrap(spacing:8,crossAxisAlignment:WrapCrossAlignment.center,children:[
      if(presentation==StateIndicatorPresentation.led||presentation==StateIndicatorPresentation.dot)
        Container(width:presentation==StateIndicatorPresentation.led?18:10,height:presentation==StateIndicatorPresentation.led?18:10,decoration:BoxDecoration(shape:BoxShape.circle,color:state.color,border:presentation==StateIndicatorPresentation.led?Border.all(color:t.foreground,width:2):null))
      else Icon(state.icon,color:state.color,size:18),Text(state.label,style:t.labelStyle.copyWith(color:t.foreground)),
    ]))));}
}
