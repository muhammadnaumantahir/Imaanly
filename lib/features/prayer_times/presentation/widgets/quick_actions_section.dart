                        ),
                      ),
                    ),
                    SizedBox(height: PrayerDimensions.space12),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: PrayerDimensions.pagePadding,
                        ),
                        itemCount: AthanAudio.values.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: PrayerDimensions.space8),
                        itemBuilder: (context, index) {
                          final athan = AthanAudio.values[index];
                          final isSelected = selected == athan;
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(