﻿<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">
		<xsl:apply-templates select="Diagnosis/Forest/Tree"/>
	</xsl:template>

	<xsl:template match="Diagnosis/Forest/Tree">
	<forest>
		<tree>
			<xsl:for-each select=".//Node">
			<node>
				<id><xsl:value-of select="normalize-space(@Name)"/></id>
			
					<xsl:if test="Non_Additive_Character != '' and position() != 1">
					<transformations>
						<xsl:for-each select="Non_Additive_Character">
							<xsl:variable name="characterName" select="@Name"/>
							<xsl:variable name="entityPosition" select="position()"/>
							<xsl:variable name="ancestorValue" select="normalize-space(../../../Node/*[$entityPosition])"/>
							<xsl:variable name="descendantValue" select="normalize-space(.)"/>
							<xsl:if test="( $descendantValue != $ancestorValue ) and @Class='Final'">
							<transformation>
								<xsl:choose>
									<xsl:when test="translate($descendantValue,'ACGT- ','') = '' and (count(child::*) = string-length(translate($descendantValue,' ','')))">
										<xsl:variable name="ancA" select="contains($ancestorValue, 'A')"/>
										<xsl:variable name="ancC" select="contains($ancestorValue, 'C')"/>
										<xsl:variable name="ancG" select="contains($ancestorValue, 'G')"/>
										<xsl:variable name="ancT" select="contains($ancestorValue, 'T')"/>
										<xsl:variable name="anc-" select="contains($ancestorValue, '-')"/>
										<xsl:variable name="descA" select="contains($descendantValue, 'A')"/>
										<xsl:variable name="descC" select="contains($descendantValue, 'C')"/>
										<xsl:variable name="descG" select="contains($descendantValue, 'G')"/>
										<xsl:variable name="descT" select="contains($descendantValue, 'T')"/>
										<xsl:variable name="desc-" select="contains($descendantValue, '-')"/>
										<xsl:variable name="ancSize">
											<xsl:choose>
												<xsl:when test="($ancA and $ancC) and ($ancG and $ancT)">
													<xsl:text>0</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="number($ancA)+number($ancC)+number($ancG)+number($ancT)"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:variable name="descSize">
											<xsl:choose>
												<xsl:when test="($descA and $descC) and ($descG and $descT)">
													<xsl:text>0</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="number($descA)+number($descC)+number($descG)+number($descT)"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:variable name="intersectionSize" select="
											number($ancA and $descA) +
											number($ancC and $descC) + 
											number($ancG and $descG) +
											number($ancT and $descT)"/>
										<xsl:attribute name="Character"><xsl:value-of select="substring-before(@Name,':')"/></xsl:attribute>
										<xsl:attribute name="Pos"><xsl:value-of select="substring-after(@Name,':')"/></xsl:attribute>
										<xsl:attribute name="AncS">
										<xsl:if test="$ancA">A</xsl:if>
										<xsl:if test="$ancC">C</xsl:if>
										<xsl:if test="$ancG">G</xsl:if>
										<xsl:if test="$ancT">T</xsl:if>
										<xsl:if test="$anc-">-</xsl:if>
										</xsl:attribute>
										<xsl:attribute name="DescS">
										<xsl:if test="$descA">A</xsl:if>
										<xsl:if test="$descC">C</xsl:if>
										<xsl:if test="$descG">G</xsl:if>
										<xsl:if test="$descT">T</xsl:if>
										<xsl:if test="$desc-">-</xsl:if>
										</xsl:attribute>
										<xsl:attribute name="Type">
										<xsl:choose>
											<xsl:when test="$ancSize = 0">Ins</xsl:when>
											<xsl:when test="$descSize = 0">Del</xsl:when>
											<xsl:otherwise>
												<xsl:choose>
													<!-- when intersection is empty set or there is a state of length 3, it's not definite -->
													<xsl:when test="$intersectionSize != 0 or ($ancSize = 3 or $descSize=3)">ABC</xsl:when>
													<!-- changes between states of set size 1 -->
													<xsl:when test="$ancSize = 1 and $descSize = 1">
														<xsl:choose>
															<xsl:when test="(($ancA or $ancG) and ($descC or $descT)) or
															(($ancC or $ancT) and ($descA or $descG))">Tv</xsl:when>
															<xsl:otherwise>Ti</xsl:otherwise>
														</xsl:choose>
													</xsl:when>
													<!-- changes between states of set size 2 -->
													<xsl:when test="$ancSize = 2 and $descSize = 2">
														<xsl:choose>
															<xsl:when test="($ancA and $ancG) or ($ancC and $ancT)">Tv</xsl:when>
															<xsl:otherwise>ABC</xsl:otherwise>
														</xsl:choose>
													</xsl:when>
													<!-- cases left: set sizes of 1 and 2 -->
													<xsl:otherwise>
														<xsl:choose>
															<xsl:when test="
															($ancA and not($descG)) or
															($ancC and not($descT)) or
															($ancG and not($descA)) or
															($ancT and not($descC))
															">Tv</xsl:when>
															<xsl:otherwise>ABC</xsl:otherwise>
														</xsl:choose>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:otherwise>
										</xsl:choose>
										</xsl:attribute>
										<xsl:attribute name="Cost"><xsl:value-of select="@Cost"/></xsl:attribute>
										<xsl:attribute name="Definite">
										<xsl:choose>
											<xsl:when test="$intersectionSize != 0">false</xsl:when>
											<xsl:otherwise>true</xsl:otherwise>
										</xsl:choose>
										</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="Character"><xsl:value-of select="translate(@Name,'_',' ')"/></xsl:attribute>
										<xsl:attribute name="AncS"><xsl:value-of select="translate($ancestorValue,'_',' ')"/></xsl:attribute>
										<xsl:attribute name="DescS"><xsl:value-of select="translate($descendantValue,'_',' ')"/></xsl:attribute>
										<xsl:attribute name="Type">non-additive character</xsl:attribute>
										<xsl:attribute name="Cost"><xsl:value-of select="@Cost"/></xsl:attribute>
										<xsl:attribute name="Definite"><xsl:value-of select="@Definite"/></xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
							</transformation>
							</xsl:if>
						</xsl:for-each>
					</transformations>
					</xsl:if>
					
					<xsl:if test="Additive_Character != '' and position() != 1">
						<xsl:for-each select="Additive_Character">
							<xsl:variable name="characterName" select="@Name"/>
							<xsl:variable name="entityPosition" select="position()"/>
							<xsl:variable name="ancestorMin" select="normalize-space(../../../Node/*[$entityPosition]/Min)"/>
							<xsl:variable name="ancestorMax" select="normalize-space(../../../Node/*[$entityPosition]/Max)"/>
							<xsl:if test="(( normalize-space(Min) != $ancestorMin ) or ( normalize-space(Max) != $ancestorMax )) and @Class='Final'">
								<xsl:text>&#10;&#10;transformation</xsl:text>
								<xsl:text>&#10;&#10;&#x09;character           : </xsl:text>
								<xsl:value-of select="translate(@Name,'_',' ')"/>
								<xsl:text>&#10;&#x09;ancestor state      : </xsl:text>
								<xsl:choose>
									<xsl:when test="$ancestorMin = $ancestorMax">
										<xsl:value-of select="translate($ancestorMin,'_',' ')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="translate($ancestorMin,'_',' ')"/> - <xsl:value-of select="translate($ancestorMax,'_',' ')"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>&#10;&#x09;descendant state    : </xsl:text>
								<xsl:choose>
									<xsl:when test="normalize-space(Min) = normalize-space(Max)">
										<xsl:value-of select="translate(normalize-space(Min),'_',' ')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="translate(normalize-space(Min),'_',' ')"/> - <xsl:value-of select="translate(normalize-space(Max),'_',' ')"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>&#10;&#x09;type                : additive character</xsl:text>
								<xsl:text>&#10;&#x09;cost                : </xsl:text>
								<xsl:value-of select="@Cost"/>
								<xsl:text>&#10;&#x09;definite            : </xsl:text>
								<xsl:value-of select="@Definite"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					
					<xsl:if test="Sankoff_Character != '' and position() != 1">
						<xsl:for-each select="Sankoff_Character">
							<xsl:variable name="characterName" select="@Name"/>
							<xsl:variable name="entityPosition" select="position()"/>
							<xsl:variable name="ancestorValue" select="normalize-space(../../../Node/*[$entityPosition]/Value)"/>
							<xsl:if test="normalize-space(Value) != $ancestorValue and @Class='Final'">
								<xsl:text>&#10;&#10;transformation</xsl:text>
								<xsl:text>&#10;&#10;&#x09;character           : </xsl:text>
								<xsl:value-of select="substring-before(@Name,':')"/>
								<xsl:text>&#10;&#x09;position            : </xsl:text>
								<xsl:value-of select="substring-after(@Name,':')"/>
								<xsl:text>&#10;&#x09;ancestor state      : </xsl:text>
								<xsl:value-of select="$ancestorValue"/>
								<xsl:text>&#10;&#x09;descendant state    : </xsl:text>
								<xsl:value-of select="normalize-space(Value)"/>
								<xsl:text>&#10;&#x09;type                : sankoff character</xsl:text>
								<xsl:text>&#10;&#x09;cost                : </xsl:text>
								<xsl:value-of select="@Cost"/>
								<xsl:text>&#10;&#x09;definite            : </xsl:text>
								<xsl:value-of select="@Definite"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					
					<xsl:if test="Sequence != '' and position() != 1">
						<xsl:for-each select="Sequence">
							<xsl:variable name="characterName" select="@Name"/>
							<xsl:variable name="entityPosition" select="position()"/>
							<xsl:variable name="ancestorValue" select="normalize-space(../../../Node/*[$entityPosition])"/>
							<xsl:if test="normalize-space(.) != $ancestorValue and @Class='Single'">
								<xsl:text>&#10;&#10;transformation</xsl:text>
								<xsl:text>&#10;&#10;&#x09;character           : </xsl:text>
								<xsl:value-of select="substring-before($characterName,':')"/>
								<xsl:text>&#10;&#x09;sequence            : </xsl:text>
								<xsl:value-of select="substring-after($characterName,':')"/>
								<xsl:text>&#10;&#x09;ancestor sequence   : </xsl:text>
								<xsl:value-of select="$ancestorValue"/>
								<xsl:text>&#10;&#x09;descendant sequence : </xsl:text>
								<xsl:value-of select="normalize-space(.)"/>
								<xsl:text>&#10;&#x09;type                : sequence</xsl:text>
								<xsl:text>&#10;&#x09;cost                : </xsl:text>
								<xsl:value-of select="@Cost"/>
								<xsl:text>&#10;&#x09;definite            : </xsl:text>
								<xsl:value-of select="@Definite"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					
					<xsl:if test="Breakinv != '' and position() != 1">
						<xsl:for-each select="Breakinv">
							<xsl:variable name="characterName" select="@Name"/>
							<xsl:variable name="entityPosition" select="position()"/>
							<xsl:variable name="ancestorValue" select="normalize-space(../../../Node/*[$entityPosition])"/>
							<xsl:if test="(normalize-space(.) != $ancestorValue) and @Class='Single'">
								<xsl:variable name="totalCost" select="@Cost"/>
								<xsl:variable name="rearrangementCost" select="@Rearrangment_Cost"/>
								<xsl:text>&#10;&#10;transformation</xsl:text>
								<xsl:text>&#10;&#10;&#x09;character           : </xsl:text>
								<xsl:value-of select="substring-before($characterName,':')"/>
								<xsl:text>&#10;&#x09;sequence            : </xsl:text>
								<xsl:value-of select="substring-after($characterName,':')"/>
								<xsl:text>&#10;&#x09;ancestor sequence   : </xsl:text>
								<xsl:value-of select="$ancestorValue"/>
								<xsl:text>&#10;&#x09;descendant sequence : </xsl:text>
								<xsl:value-of select="normalize-space(.)"/>
								<xsl:text>&#10;&#x09;type                : breakinv</xsl:text>
								<xsl:text>&#10;&#x09;edit cost           : </xsl:text>
								<xsl:value-of select="$totalCost - $rearrangementCost"/>
								<xsl:text>&#10;&#x09;rearrangement cost  : </xsl:text>
								<xsl:value-of select="$rearrangementCost"/>
								<xsl:text>&#10;&#x09;total cost          : </xsl:text>
								<xsl:value-of select="$totalCost"/>
								<xsl:text>&#10;&#x09;definite            : </xsl:text>
								<xsl:value-of select="@Definite"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					
					<xsl:if test="Chromosome != '' and position() != 1">
						<xsl:for-each select="Chromosome">
							<xsl:if test="@Class='Single'">
								<xsl:variable name="totalCost" select="translate(substring-before(@Cost,'-'),' ','')"/>
								<xsl:variable name="rearrangementCost" select="@Rearrangment_Cost"/>
								<xsl:text>&#10;&#10;transformation map</xsl:text>
								<xsl:text>&#10;&#10;&#x09;character           : </xsl:text>
								<xsl:value-of select="translate(@Name,'_',' ')"/>
								<xsl:text>&#10;&#x09;type:chromosome</xsl:text>
								<xsl:text>&#10;&#x09;edit cost           : </xsl:text>
								<xsl:value-of select="$totalCost - $rearrangementCost"/>
								<xsl:text>&#10;&#x09;rearrangement cost  : </xsl:text>
								<xsl:value-of select="$rearrangementCost"/>
								<xsl:text>&#10;&#x09;total cost          : </xsl:text>
								<xsl:value-of select="$totalCost"/>
								<xsl:text>&#10;&#x09;definite            : </xsl:text>
								<xsl:value-of select="@Definite"/>
								<xsl:variable name="ancestorSequence" select="normalize-space(Sequence)"/>
								<xsl:variable name="descendantReferenceCode" select="ChromosomeMap/SegmentMap/@DescendantReferenceCode"/>
								<xsl:variable name="descendantSequence" select="normalize-space(../..//Chromosome[@ReferenceCode = $descendantReferenceCode][@Class = 'Single']/Sequence)"/>
								<xsl:text>&#10;&#x09;ancestor sequence   : </xsl:text>
								<xsl:value-of select="$ancestorSequence"/>
								<xsl:text>&#10;&#x09;descendant sequence : </xsl:text>
								<xsl:value-of select="$descendantSequence"/>
								<xsl:choose>
									<xsl:when test="ChromosomeMap/SegmentMap/@AncestorStartPosition != ''">
									<!-- non-annotated -->
										<xsl:for-each select="ChromosomeMap//SegmentMap">
											<!-- output ancestor set -->
											<xsl:text>&#10;	   [</xsl:text>
											<xsl:choose>
												<xsl:when test="@AncestorDirection != '+'">
													<xsl:value-of select="@AncestorEndPosition"/>
													<xsl:text>,</xsl:text>
													<xsl:value-of select="@AncestorStartPosition"/>
												</xsl:when>
												<xsl:when test="@AncestorStartPosition = -1">
													<xsl:text/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="@AncestorStartPosition"/>
													<xsl:text>,</xsl:text>
													<xsl:value-of select="@AncestorEndPosition"/>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:text>] -> [</xsl:text>
											<!-- output descendant set -->
											<xsl:choose>
												<xsl:when test="@DescendantDirection != '+'">
													<xsl:value-of select="@DescendantEndPosition"/>
													<xsl:text>,</xsl:text>
													<xsl:value-of select="@DescendantStartPosition"/>
												</xsl:when>
												<xsl:when test="@DescendantStartPosition = -1">
													<xsl:text/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="@DescendantStartPosition"/>
													<xsl:text>,</xsl:text>
													<xsl:value-of select="@DescendantEndPosition"/>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:text>] :: </xsl:text>
											<!-- output type of trans -->
											<xsl:choose>
												<xsl:when test="@AncestorStartPosition = -1">
													<xsl:text>origin</xsl:text>
												</xsl:when>
												<xsl:when test="@DescendantStartPosition = -1">
													<xsl:text>loss</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:variable name="change" select="@AncestorStartPosition != @DescendantStartPosition or @AncestorEndPosition != @DescendantEndPosition"/>
													<xsl:variable name="inversion" select="@AncestorDirection != @DescendantDirection"/>
													<xsl:variable name="transformation" select="$change or $inversion"/>
													<xsl:if test="$change">
														<xsl:text>change </xsl:text>
													</xsl:if>
													<xsl:if test="$inversion">
														<xsl:text>inversion</xsl:text>
													</xsl:if>
													<xsl:if test="not($transformation)">
														<xsl:text>no change</xsl:text>
													</xsl:if>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
									<!-- annotated -->
										<xsl:for-each select="ChromosomeMap//SegmentMap">
											<xsl:text>&#10;	   [</xsl:text>
											<xsl:value-of select="@AncestorSequenceOrder"/>
											<xsl:text>] -> [</xsl:text>
											<xsl:value-of select="@DescendantSequenceOrder"/>
											<xsl:text>] :: </xsl:text>
											<xsl:choose>
												<xsl:when test="@AncestorSequenceOrder = -1">
													<xsl:text>origin</xsl:text>
												</xsl:when>
												<xsl:when test="@DescendantSequenceOrder = -1">
													<xsl:text>loss</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:choose>
														<xsl:when test="@AncestorSequenceOrder != @DescendantSequenceOrder or @AncestorDirection != @DescendantDirection">
															<xsl:if test="@AncestorSequenceOrder != @DescendantSequenceOrder">
																<xsl:text>rearrangement </xsl:text>
															</xsl:if>
															<xsl:if test="@AncestorDirection != @DescendantDirection">
																<xsl:text>inversion</xsl:text>
															</xsl:if>
														</xsl:when>
														<xsl:otherwise>
															<xsl:text>no change</xsl:text>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					
					<xsl:if test="Genome != '' and position() != 1">
						<xsl:for-each select="Genome">
							<xsl:if test="@Class='Single'">
								<xsl:variable name="totalCost" select="translate(substring-before(@Cost,'-'),' ','')"/>
								<xsl:variable name="rearrangementCost" select="@Rearrangment_Cost"/>
								<xsl:text>&#10;&#10;transformation map</xsl:text>
								<xsl:text>&#10;&#10;&#x09;character           : </xsl:text>
								<xsl:value-of select="translate(@Name,'_',' ')"/>
								<xsl:text>&#10;&#x09;type                : multi-chromosome</xsl:text>
								<xsl:text>&#10;&#x09;edit cost           : </xsl:text>
								<xsl:value-of select="$totalCost - $rearrangementCost"/>
								<xsl:text>&#10;&#x09;rearrangement cost  : </xsl:text>
								<xsl:value-of select="$rearrangementCost"/>
								<xsl:text>&#10;&#x09;total cost          : </xsl:text>
								<xsl:value-of select="$totalCost"/>
								<xsl:text>&#10;&#x09;definite            : </xsl:text>
								<xsl:value-of select="@Definite"/>
								<xsl:variable name="ancestorReferenceCode" select="GenomeMap/@AncestorReferenceCode"/>
								<xsl:variable name="ancestorSequence" select="normalize-space(../../../Node/Genome[@ReferenceCode = $ancestorReferenceCode][@Class='Single']/Sequence)"/>
								<xsl:variable name="descendantSequence" select="normalize-space(Sequence)"/>
								<xsl:text>&#10;&#x09;ancestor sequence   : </xsl:text>
								<xsl:value-of select="$ancestorSequence"/>
								<xsl:text>&#10;&#x09;descendant sequence : </xsl:text>
								<xsl:value-of select="$descendantSequence"/>
								<xsl:choose>
									<xsl:when test="GenomeMap/ChromosomeMap/SegmentMap/@AncestorStartPosition != ''">
									<!-- non-annotated -->
										<xsl:for-each select="GenomeMap/ChromosomeMap//SegmentMap">
											<!-- output ancestor set -->
											<xsl:text>&#10;	   c</xsl:text>
											<xsl:value-of select="@AncestorChromosomeID"/>
											<xsl:text>.:[</xsl:text>
											<xsl:choose>
												<xsl:when test="@AncestorDirection != '+'">
													<xsl:value-of select="@AncestorEndPosition"/>
													<xsl:text>,</xsl:text>
													<xsl:value-of select="@AncestorStartPosition"/>
												</xsl:when>
												<xsl:when test="@AncestorStartPosition = -1">
													<xsl:text/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="@AncestorStartPosition"/>
													<xsl:text>,</xsl:text>
													<xsl:value-of select="@AncestorEndPosition"/>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:text>] -> c</xsl:text>
											<!-- output descendant set -->
											<xsl:value-of select="@DescendantChromosomeID"/>
											<xsl:text>.:[</xsl:text>
											<xsl:choose>
												<xsl:when test="@DescendantDirection != '+'">
													<xsl:value-of select="@DescendantEndPosition"/>
													<xsl:text>,</xsl:text>
													<xsl:value-of select="@DescendantStartPosition"/>
												</xsl:when>
												<xsl:when test="@DescendantStartPosition = -1">
													<xsl:text/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="@DescendantStartPosition"/>
													<xsl:text>,</xsl:text>
													<xsl:value-of select="@DescendantEndPosition"/>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:text>] :: </xsl:text>
											<!-- output type of trans -->
											<xsl:choose>
												<xsl:when test="@AncestorStartPosition = -1">
													<xsl:text>origin</xsl:text>
												</xsl:when>
												<xsl:when test="@DescendantStartPosition = -1">
													<xsl:text>loss</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:variable name="change" select="@AncestorStartPosition != @DescendantStartPosition or @AncestorEndPosition != @DescendantEndPosition"/>
													<xsl:variable name="inversion" select="@AncestorDirection != @DescendantDirection"/>
													<xsl:variable name="jump" select="@AncestorChromosomeID != @DescendantChromosomeID"/>
													<xsl:variable name="transformation" select="$change or $inversion or $jump"/>
													<xsl:if test="$change">
														<xsl:text>change </xsl:text>
													</xsl:if>
													<xsl:if test="$inversion">
														<xsl:text>inversion </xsl:text>
													</xsl:if>
													<xsl:if test="$jump">
														<xsl:text>jump</xsl:text>
													</xsl:if>
													<xsl:if test="not($transformation)">
														<xsl:text>no change</xsl:text>
													</xsl:if>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
									<!-- annotated -->
										<xsl:for-each select="ChromosomeMap//SegmentMap">
											<xsl:text>&#10;	   [</xsl:text>
											<xsl:value-of select="@AncestorSequenceOrder"/>
											<xsl:text>] -> [</xsl:text>
											<xsl:value-of select="@DescendantSequenceOrder"/>
											<xsl:text>] :: </xsl:text>
											<xsl:choose>
												<xsl:when test="@AncestorSequenceOrder = -1">
													<xsl:text>origin</xsl:text>
												</xsl:when>
												<xsl:when test="@DescendantSequenceOrder = -1">
													<xsl:text>loss</xsl:text>
												</xsl:when>
												<xsl:otherwise>
													<xsl:choose>
														<xsl:when test="@AncestorSequenceOrder != @DescendantSequenceOrder or @AncestorDirection != @DescendantDirection or @AncestorChromosomeID != @DescendantChromosomeID">
															<xsl:if test="@AncestorSequenceOrder != @DescendantSequenceOrder">
																<xsl:text>rearrangement </xsl:text>
															</xsl:if>
															<xsl:if test="@AncestorDirection != @DescendantDirection">
																<xsl:text>inversion </xsl:text>
															</xsl:if>
															<xsl:if test="@AncestorChromosomeID != @DescendantChromosomeID">
																<xsl:text>jump</xsl:text>
															</xsl:if>
														</xsl:when>
														<xsl:otherwise>
															<xsl:text>no change</xsl:text>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:for-each>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					<!-- put ancestors if not root -->
					<xsl:if test="@Name != 'root'">
						<ancestors>
							<ancestor>
									<xsl:variable name="ancestorName" select="../../Node/@Name"></xsl:variable>
								<xsl:attribute name="id">
									<xsl:value-of select="$ancestorName"/>
								</xsl:attribute>
								<xsl:attribute name="type">
									<xsl:choose>
										<xsl:when test="$ancestorName = 'root'">
											<xsl:text>root</xsl:text>
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>node</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</ancestor>
						</ancestors>
					</xsl:if>
			</node>
			</xsl:for-each>
		</tree>
	</forest>			
	</xsl:template>
	
</xsl:stylesheet>
